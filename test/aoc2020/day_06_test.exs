defmodule Aoc2020.Day06Test do
  use ExUnit.Case
  doctest Aoc2020.Day06

  # alias Aoc2020.Day06

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_06"])

  setup_all do
    reports = File.stream!(Path.join(@data_dir, "input"))

    {:ok, reports: reports}
  end

  test "part one"

  test "part two"
end
