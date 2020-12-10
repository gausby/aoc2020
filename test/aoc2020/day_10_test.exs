defmodule Aoc2020.Day10Test do
  use ExUnit.Case
  doctest Aoc2020.Day10

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_10"])

  setup_all do
    adapters =
      for line <- File.stream!(Path.join(@data_dir, "input")),
          {number, _new_line} = Integer.parse(line) do
        number
      end

    {:ok, adapters: adapters}
  end

  describe "part one" do
    test "example"

    test "actual data"
  end

  describe "part two" do
    test "example data"

    test "actual data"
  end
end
