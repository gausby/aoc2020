defmodule Aoc2020.Day08 do
  @moduledoc """
  Day 8: Handheld Halting

  ## Part One

  Your flight to the major airline hub reaches cruising altitude
  without incident. While you consider checking the in-flight menu for
  one of those drinks that come with a little umbrella, you are
  interrupted by the kid sitting next to you.

  Their handheld game console won't turn on! They ask if you can take
  a look.

  You narrow the problem down to a strange infinite loop in the boot
  code (your puzzle input) of the device. You should be able to fix
  it, but first you need to be able to run the code in isolation.

  The boot code is represented as a text file with one instruction per
  line of text. Each instruction consists of an operation (acc, jmp,
  or nop) and an argument (a signed number like +4 or -20).

  - `acc` increases or decreases a single global value called the
    accumulator by the value given in the argument. For example, acc
    +7 would increase the accumulator by 7. The accumulator starts at
    0. After an acc instruction, the instruction immediately below it
    is executed next.

  - `jmp` jumps to a new instruction relative to itself. The next
    instruction to execute is found using the argument as an offset
    from the jmp instruction; for example, jmp +2 would skip the next
    instruction, jmp +1 would continue to the instruction immediately
    below it, and jmp -20 would cause the instruction 20 lines above
    to be executed next.

  - `nop` stands for No OPeration - it does nothing. The instruction
    immediately below it is executed next.

  For example, consider the following program:

      nop +0
      acc +1
      jmp +4
      acc +3
      jmp -3
      acc -99
      acc +1
      jmp -4
      acc +6

  These instructions are visited in this order:

      nop +0  | 1
      acc +1  | 2, 8(!)
      jmp +4  | 3
      acc +3  | 6
      jmp -3  | 7
      acc -99 |
      acc +1  | 4
      jmp -4  | 5
      acc +6  |

  First, the nop +0 does nothing. Then, the accumulator is increased
  from 0 to 1 (acc +1) and jmp +4 sets the next instruction to the
  other acc +1 near the bottom. After it increases the accumulator
  from 1 to 2, jmp -4 executes, setting the next instruction to the
  only acc +3. It sets the accumulator to 5, and jmp -3 causes the
  program to continue back at the first acc +1.

  This is an infinite loop: with this sequence of jumps, the program
  will run forever. The moment the program tries to run any
  instruction a second time, you know it will never terminate.

  Immediately before the program would run an instruction a second
  time, the value in the accumulator is 5.

  Run your copy of the boot code. Immediately before any instruction
  is executed a second time, what value is in the accumulator?

  ## Part Two

  ...
  """

  defmodule Tokenizer.Helpers do
    import NimbleParsec

    def to_int(["+", v]), do: v
    def to_int(["-", v]), do: -1 * v

    def argument do
      ascii_string([?+, ?-], 1)
      |> integer(min: 1)
      |> reduce({__MODULE__, :to_int, []})
    end

    def operation(tag, name) do
      ignore(string(name) |> string(" "))
      |> concat(argument())
      |> unwrap_and_tag(tag)
    end

    def instructions(token_comb) do
      repeat =
        ignore(ascii_string([?\n], min: 0))
        |> concat(token_comb)

      times(token_comb, repeat, min: 0)
    end
  end

  defmodule Tokenizer do
    import NimbleParsec
    import __MODULE__.Helpers

    defparsec(
      :parse,
      instructions(
        choice([
          operation(:nop, "nop"),
          operation(:jmp, "jmp"),
          operation(:acc, "acc")
        ])
      )
      |> ignore(ascii_string([?\s, ?\n], min: 0))
      |> eos()
    )
  end

  defmodule Interpreter do
    defstruct acc: 0, pos: 0, rope: {[], []}

    alias __MODULE__
    alias Aoc2020.Day08.Tokenizer

    @doc """
    Create a new interpreter with a list of codes
    """
    def new(tokens) when is_list(tokens) do
      %Interpreter{rope: {tokens, []}}
    end

    @doc """
    Load a source file (or binary) into the interpreter
    """
    def load(<<source::binary>>) do
      {:ok, tokens, "", _, _, _} = Tokenizer.parse(source)
      new(tokens)
    end

    def load(%File.Stream{} = stream) do
      for operation <- stream, into: [] do
        {:ok, token, "", _, _, _} = Tokenizer.parse(operation)
        token
      end
      |> List.flatten()
      |> new()
    end

    @doc """
    Step the program a given amount of times

    The given amount of steps is given as `fuel`; one step will
    consume one fuel, and the interpreter will halt when it has run
    out of fuel; at which point you can give it some more, or don't,
    whatever, I don't tell you what to do.
    """
    def step(interpreter, fuel \\ 1)
    def step(%Interpreter{} = interpreter, 0), do: interpreter

    def step(%Interpreter{rope: {[_ | _], _behind}} = state, fuel) when fuel > 0 do
      step(handle_token(state), fuel - 1)
    end

    # Handle the input current opcode ----------------------------------
    defp handle_token(%Interpreter{rope: {[{:nop, _} | _], _behind}} = state) do
      # skip to next
      move(state, 1)
    end

    defp handle_token(%Interpreter{rope: {[{:acc, value} | _], _behind}} = state) do
      %Interpreter{state | acc: state.acc + value} |> move(1)
    end

    defp handle_token(%Interpreter{rope: {[{:jmp, value} | _], _behind}} = state) do
      move(state, value)
    end

    # Move the opcodes in the rope, allow us to jump back and forth in
    # the program we are interpreting, and we will only have to add
    # and remove from the head of the lists in our rope; now, that is
    # a beauty !
    defp move(interpreter, 0), do: interpreter

    defp move(
           %Interpreter{
             rope: {[front | rest], behind}
           } = state,
           n
         )
         when n > 0 do
      # move from the front to the back
      move(
        %Interpreter{state | rope: {rest, [front | behind]}, pos: state.pos + 1},
        n - 1
      )
    end

    defp move(%Interpreter{rope: {front, [head | behind]}} = state, n) when n < 0 do
      # move from the back to the front
      move(
        %Interpreter{state | rope: {[head | front], behind}, pos: state.pos - 1},
        n + 1
      )
    end

    # Warning; pure GENIUS is coming up !!!

    # FEAST YOUR EYES ON THIS!!!
    defimpl Enumerable do
      alias Aoc2020.Day08.Interpreter

      def count(%Interpreter{rope: {front, back}}) do
        length(front) + length(back)
      end

      def reduce(_state, {:halt, acc}, _fun), do: {:halted, acc}

      def reduce(state, {:suspend, acc}, fun),
        do: {:suspended, acc, &reduce(state, &1, fun)}

      def reduce(%Interpreter{rope: {[], _back}}, {:cont, acc}, _fun),
        do: {:done, acc}

      def reduce(%Interpreter{rope: {[_ | _], _}} = state, {:cont, acc}, fun) do
        state = Interpreter.step(state)
        reduce(state, fun.(state, acc), fun)
      end

      def slice(%Interpreter{}) do
        {:error, __MODULE__}
      end

      def member?(%Interpreter{}, _) do
        {:error, __MODULE__}
      end
    end

    # ...is it smart? Probably not.
  end
end
