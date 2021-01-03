defmodule Aoc2020.Day11Test do
  use ExUnit.Case
  doctest Aoc2020.Day11

  alias Aoc2020.Day11.Seating

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_11"])

  setup_all do
    # adapters =
    #   for line <- File.stream!(Path.join(@data_dir, "input")),
    #       {number, _new_line} = Integer.parse(line) do
    #     number
    #   end
    layout = File.read!(Path.join(@data_dir, "input"))

    {:ok, layout: layout}
  end

  describe "part one" do
    test "example" do
      layout = """
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
      """

      assert 37 ==
               Seating.new(layout)
               |> Enum.reduce_while(nil, fn
                 %Seating{occupied: val} = stable, val ->
                   {:halt, stable}

                 %Seating{occupied: occupied}, _val ->
                   {:cont, occupied}
               end)
               |> Seating.occupied()
    end

    @tag timeout: :infinity
    test "actual data", %{layout: layout} do
      assert 2344 ==
               Seating.new(layout)
               |> Enum.reduce_while(nil, fn
                 %Seating{occupied: val} = stable, val ->
                   {:halt, stable}

                 %Seating{occupied: occupied}, _val ->
                   {:cont, occupied}
               end)
               |> Seating.occupied()
    end
  end

  describe "part two" do
    @tag skip: true
    test "example data"

    @tag skip: true
    test "actual data"
  end
end
