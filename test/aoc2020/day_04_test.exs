defmodule Aoc2020Test.Day04Test do
  use ExUnit.Case
  doctest Aoc2020.Day04

  # alias Aoc2020.Day04

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_04"])

  setup_all do
    data = File.stream!(Path.join(@data_dir, "input"))
    {:ok, data: data}
  end

  test "part one"

  test "part two"
end
