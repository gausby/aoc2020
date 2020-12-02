defmodule Aoc2020Test.Day02Test do
  use ExUnit.Case
  doctest Aoc2020.Day02

  alias Aoc2020.Day02

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_02"])

  test "level 1" do
    input = File.stream!(Path.join(@data_dir, "input"))
    opts = [policy_version: Day02.Policy.V1]
    assert 467 == Enum.count(input, &Day02.valid?(&1, opts))
  end

  test "level 2" do
    input = File.stream!(Path.join(@data_dir, "input"))
    opts = [policy_version: Day02.Policy.V2]
    assert 441 = Enum.count(input, &Day02.valid?(&1, opts))
  end
end
