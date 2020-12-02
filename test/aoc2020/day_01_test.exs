defmodule Aoc2020Test.Day01Test do
  use ExUnit.Case
  doctest Aoc2020.Day01

  alias Aoc2020.Day01

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_01"])

  setup_all do
    reports =
      for line <- File.stream!(Path.join(@data_dir, "input")),
          {number, _new_line} = Integer.parse(line) do
        number
      end

    {:ok, reports: reports}
  end

  test "part one", %{reports: reports} do
    assert [876_459] == Day01.find_matches(reports, entries: 2, sum: 2020)
  end

  test "part two", %{reports: reports} do
    assert [116_168_640] == Day01.find_matches(reports, entries: 3, sum: 2020)
  end
end
