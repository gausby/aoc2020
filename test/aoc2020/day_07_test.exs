defmodule Aoc2020.Day07Test do
  use ExUnit.Case
  doctest Aoc2020.Day07

  alias Aoc2020.Day07
  alias Aoc2020.Day07.{RuleParser, RuleGraph}

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_07"])

  setup_all do
    rule_tokens =
      for line <- File.stream!(Path.join(@data_dir, "input")),
          tokens = Day07.RuleParser.parse(line) do
        tokens
      end

    {:ok, rule_tokens: rule_tokens}
  end

  describe "part one" do
    test "example" do
      {:ok, graph} =
        """
        light red bags contain 1 bright white bag, 2 muted yellow bags.
        dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        bright white bags contain 1 shiny gold bag.
        muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        faded blue bags contain no other bags.
        dotted black bags contain no other bags.
        """
        |> String.split("\n", trim: true)
        |> Enum.map(&RuleParser.parse/1)
        |> RuleGraph.from_tokens()

      assert 4 == Enum.count(RuleGraph.fits_in(graph, {"shiny", "gold"}))
    end

    test "actual data", %{rule_tokens: rule_tokens} do
      {:ok, graph} = RuleGraph.from_tokens(rule_tokens)
      assert 246 == Enum.count(RuleGraph.fits_in(graph, {"shiny", "gold"}))
    end
  end

  describe "part two" do
    test "example" do
      {:ok, graph} =
        """
        light red bags contain 1 bright white bag, 2 muted yellow bags.
        dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        bright white bags contain 1 shiny gold bag.
        muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        faded blue bags contain no other bags.
        dotted black bags contain no other bags.
        """
        |> String.split("\n", trim: true)
        |> Enum.map(&RuleParser.parse/1)
        |> RuleGraph.from_tokens()

      assert 32 == RuleGraph.total_bags_contained(graph, {"shiny", "gold"})
    end

    test "another example" do
      {:ok, graph} =
        """
        shiny gold bags contain 2 dark red bags.
        dark red bags contain 2 dark orange bags.
        dark orange bags contain 2 dark yellow bags.
        dark yellow bags contain 2 dark green bags.
        dark green bags contain 2 dark blue bags.
        dark blue bags contain 2 dark violet bags.
        dark violet bags contain no other bags.
        """
        |> String.split("\n", trim: true)
        |> Enum.map(&RuleParser.parse/1)
        |> RuleGraph.from_tokens()

      assert 126 == RuleGraph.total_bags_contained(graph, {"shiny", "gold"})
    end

    test "actual data", %{rule_tokens: rule_tokens} do
      {:ok, graph} = RuleGraph.from_tokens(rule_tokens)
      assert 2976 == RuleGraph.total_bags_contained(graph, {"shiny", "gold"})
    end
  end
end
