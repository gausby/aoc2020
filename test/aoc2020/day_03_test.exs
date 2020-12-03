defmodule Aoc2020Test.Day03Test do
  use ExUnit.Case
  doctest Aoc2020.Day03

  alias Aoc2020.Day03.Terrain

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_03"])

  setup_all do
    map_stream = File.stream!(Path.join(@data_dir, "input"))
    {:ok, map: map_stream}
  end

  test "Part One", %{map: map_input} do
    assert 211 ==
             Terrain.new(map_input)
             |> Terrain.add_cursor({:foo, x: 0, y: 0})
             |> Terrain.action(:foo, {:repeat, [{:right, 3}, {:down, 1}, :observe]})
             |> Terrain.collect(:foo)
             |> Enum.count(&match?({_, true}, &1))
  end

  test "Part Two"
end
