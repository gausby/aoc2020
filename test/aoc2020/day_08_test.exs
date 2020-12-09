defmodule Aoc2020.Day08Test do
  use ExUnit.Case
  doctest Aoc2020.Day08

  # alias Aoc2020.Day08
  alias Aoc2020.Day08.{Tokenizer, Interpreter}

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_08"])

  setup_all do
    source = File.stream!(Path.join(@data_dir, "input"))

    {:ok, source: source}
  end

  describe "part one" do
    test "the tokenizer produce a list of tokens from input" do
      {:ok, tokens, "", _, _, _} =
        Tokenizer.parse("""
        nop +0
        acc +1
        jmp +4
        acc +3
        jmp -3
        acc -99
        acc +1
        jmp -4
        acc +6
        """)

      assert [
               {:nop, 0},
               {:acc, 1},
               {:jmp, 4},
               {:acc, 3},
               {:jmp, -3},
               {:acc, -99},
               {:acc, 1},
               {:jmp, -4},
               {:acc, 6}
             ] == tokens

      # the intprepter starts out with an accumulator value of 0, and
      # the tokens are all in front in the rope
      assert %Interpreter{acc: 0, rope: {tokens, []}} = Interpreter.new(tokens)

      # for the first step we will move the operation to the behind of
      # the rope and the accumulator will stay at zero
      assert %Interpreter{acc: 0, rope: {_, [nop: 0]}} =
               Interpreter.new(tokens) |> Interpreter.step(1)

      # for the second step we will move the operation to the behind of
      # the rope and increment the accumulator by one
      assert %Interpreter{acc: 1, rope: {_, [acc: 1, nop: 0]}} =
               Interpreter.new(tokens) |> Interpreter.step(2)

      # for the third step we will jump, and we will look at an acc-1
      # token
      {behind, [_ | front]} = Enum.split(tokens, 6)
      behind = Enum.reverse(behind)

      assert %Interpreter{acc: 1, rope: {[{:acc, 1} | ^front], ^behind}} =
               Interpreter.new(tokens) |> Interpreter.step(3)

      # for the fourth step we increment the accumulator by one and
      # look at a jump backwards by four steps token
      {behind, [{:jmp, -4} | front]} = Enum.split(tokens, 7)
      behind = Enum.reverse(behind)

      assert %Interpreter{acc: 2, rope: {[{:jmp, -4} | ^front], ^behind}} =
               Interpreter.new(tokens) |> Interpreter.step(4)

      # enough of that, let's just pretend that it works; flawlessly! 
    end

    test "example interpreter" do
      source = """
      nop +0
      acc +1
      jmp +4
      acc +3
      jmp -3
      acc -99
      acc +1
      jmp -4
      acc +6
      """

      assert 5 == Interpreter.load(source) |> loop_detector()
    end

    test "actual data", %{source: source} do
      boot_loader = Interpreter.load(source)

      assert 1262 == loop_detector(boot_loader)
    end

    # see if we can detect a loop in our programs
    defp loop_detector(interpreter) do
      loop_detector_fn = fn state, {acc, seen} ->
        if MapSet.member?(seen, state.pos) do
          {:halt, acc}
        else
          {:cont, {state.acc, MapSet.put(seen, state.pos)}}
        end
      end

      initial_state = {0, MapSet.new()}

      Enum.reduce_while(interpreter, initial_state, loop_detector_fn)
    end
  end

  describe "part two" do
    test "example data" do
      example =
        Interpreter.load("""
        nop +0
        acc +1
        jmp +4
        acc +3
        jmp -3
        acc -99
        acc +1
        jmp -4
        acc +6
        """)

      assert 8 == loop_detector_(example)
    end

    test "actual data", %{source: source} do
      boot_loader = Interpreter.load(source)
      assert 1643 == loop_detector_(boot_loader)
    end

    defp loop_detector_(interpreter) do
      loop_detector_fn = fn
        %{pos: pos} = state, {_acc, order, seen} ->
          if MapSet.member?(seen, pos) do
            {:halt, {:error, order}}
          else
            {:cont, {state.acc, [pos | order], MapSet.put(seen, pos)}}
          end
      end

      initial_state = {0, [0], MapSet.new()}

      case Enum.reduce_while(interpreter, initial_state, loop_detector_fn) do
        {val, _, %MapSet{}} ->
          {:ok, val}

        {:error, visits} ->
          for {:ok, mutation} <- Enum.map(visits, &Interpreter.mutate(interpreter, &1)) do
            Enum.reduce_while(mutation, initial_state, loop_detector_fn)
          end
          |> Enum.reject(&match?({:error, _}, &1))
          |> List.first()
          |> elem(0)
      end
    end
  end
end
