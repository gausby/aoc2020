defmodule Aoc2020.Day06Test do
  use ExUnit.Case
  doctest Aoc2020.Day06

  alias Aoc2020.Day06

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_06"])

  setup_all do
    declarations = File.read!(Path.join(@data_dir, "input"))

    {:ok, declarations: declarations}
  end

  describe "part one" do
    test "example" do
      data = """
      abc

      a
      b
      c

      ab
      ac

      a
      a
      a
      a

      b
      """

      assert 11 ==
               Day06.group(data)
               |> Enum.reduce(0, &(MapSet.size(&1) + &2))
    end

    test "input file", %{declarations: declarations} do
      assert 6310 ==
               Day06.group(declarations)
               |> Enum.reduce(0, &(MapSet.size(&1) + &2))
    end
  end

  describe "part two" do
    test "example" do
      data = """
      abc

      a
      b
      c

      ab
      ac

      a
      a
      a
      a

      b
      """

      assert 6 ==
               Day06.group_intersection(data)
               |> Enum.reduce(0, &(MapSet.size(&1) + &2))
    end

    test "input file", %{declarations: declarations} do
      assert 3193 ==
               Day06.group_intersection(declarations)
               |> Enum.reduce(0, &(MapSet.size(&1) + &2))
    end
  end
end
