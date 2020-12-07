defmodule Aoc2020.Day07Test do
  use ExUnit.Case
  doctest Aoc2020.Day07

  alias Aoc2020.Day07

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_07"])

  setup_all do
    rules =
      for line <- File.stream!(Path.join(@data_dir, "input")),
          {:ok, rule, "", _, _, _} = Day07.RuleParser.parse(line) do
        rule
      end

    {:ok, rules: rules}
  end

  test "part one"

  test "part two"
end
