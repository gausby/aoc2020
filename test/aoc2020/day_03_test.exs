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

  describe "Part Two" do
    test "example" do
      map_input = """
      ..##.......
      #...#...#..
      .#....#..#.
      ..#.#...#.#
      .#...##..#.
      ..#.##.....
      .#.#.#....#
      .#........#
      #.##...#...
      #...##....#
      .#..#...#.#
      """

      assert 336 ==
               Terrain.new(map_input)
               |> Terrain.add_cursor([:one, :two, :three, :four, :five])
               |> Terrain.action(:one, {:repeat, [{:right, 1}, {:down, 1}, :observe]})
               |> Terrain.action(:two, {:repeat, [{:right, 3}, {:down, 1}, :observe]})
               |> Terrain.action(:three, {:repeat, [{:right, 5}, {:down, 1}, :observe]})
               |> Terrain.action(:four, {:repeat, [{:right, 7}, {:down, 1}, :observe]})
               |> Terrain.action(:five, {:repeat, [{:right, 1}, {:down, 2}, :observe]})
               |> Terrain.collect([:one, :two, :three, :four, :five])
               |> Enum.reduce(1, fn observations, acc ->
                 Enum.count(observations, &match?({_pos, true}, &1)) * acc
               end)
    end

    test "actual data", %{map: map_input} do
      assert 3_584_591_857 ==
               Terrain.new(map_input)
               |> Terrain.add_cursor([:one, :two, :three, :four, :five])
               |> Terrain.action(:one, {:repeat, [{:right, 1}, {:down, 1}, :observe]})
               |> Terrain.action(:two, {:repeat, [{:right, 3}, {:down, 1}, :observe]})
               |> Terrain.action(:three, {:repeat, [{:right, 5}, {:down, 1}, :observe]})
               |> Terrain.action(:four, {:repeat, [{:right, 7}, {:down, 1}, :observe]})
               |> Terrain.action(:five, {:repeat, [{:right, 1}, {:down, 2}, :observe]})
               |> Terrain.collect([:one, :two, :three, :four, :five])
               |> Enum.reduce(1, fn observations, acc ->
                 Enum.count(observations, &match?({_pos, true}, &1)) * acc
               end)
    end
  end
end
