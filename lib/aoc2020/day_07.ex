defmodule Aoc2020.Day07 do
  @moduledoc """
  Day 7: Handy Haversacks

  ## Part One

  You land at the regional airport in time for your next flight. In
  fact, it looks like you'll even have time to grab some food: all
  flights are currently delayed due to issues in luggage processing.

  Due to recent aviation regulations, many rules (your puzzle input)
  are being enforced about bags and their contents; bags must be
  color-coded and must contain specific quantities of other
  color-coded bags. Apparently, nobody responsible for these
  regulations considered how long they would take to enforce!

  For example, consider the following rules:

  - light red bags contain 1 bright white bag, 2 muted yellow bags.
  - dark orange bags contain 3 bright white bags, 4 muted yellow bags.
  - bright white bags contain 1 shiny gold bag.
  - muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
  - shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
  - dark olive bags contain 3 faded blue bags, 4 dotted black bags.
  - vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
  - faded blue bags contain no other bags.
  - dotted black bags contain no other bags.

  These rules specify the required contents for 9 bag types. In this
  example, every faded blue bag is empty, every vibrant plum bag
  contains 11 bags (5 faded blue and 6 dotted black), and so on.

  You have a shiny gold bag. If you wanted to carry it in at least one
  other bag, how many different bag colors would be valid for the
  outermost bag? (In other words: how many colors can, eventually,
  contain at least one shiny gold bag?)

  In the above rules, the following options would be available to you:

  - A bright white bag, which can hold your shiny gold bag directly.

  - A muted yellow bag, which can hold your shiny gold bag directly,
    plus some other bags.

  - A dark orange bag, which can hold bright white and muted yellow
    bags, either of which could then hold your shiny gold bag.

  - A light red bag, which can hold bright white and muted yellow
    bags, either of which could then hold your shiny gold bag.

  So, in this example, the number of bag colors that can eventually
  contain at least one shiny gold bag is 4.

  How many bag colors can eventually contain at least one shiny gold
  bag? (The list of rules is quite long; make sure you get all of it.)

  ## Part Two

  ...
  """

  defmodule RuleParser.ParserHelpers do
    import NimbleParsec

    def whitespace do
      ascii_string([?\s], min: 1)
    end

    def color do
      ascii_string([?a..?z, ?A..?Z], min: 1)
    end

    def modifier do
      ascii_string([?a..?z, ?A..?Z], min: 1)
    end

    def bag do
      unwrap_and_tag(modifier(), :modifier)
      |> ignore(whitespace())
      |> concat(unwrap_and_tag(color(), :color))
      |> ignore(whitespace())
      |> ignore(string("bag") |> optional(string("s")))
      |> tag(:bag)
    end

    def bags(bag_comb) do
      repeat =
        ignore(ascii_string([?\s, ?\,], min: 0))
        |> concat(bag_comb)

      times(bag_comb, repeat, min: 0)
    end
  end

  defmodule RuleParser do
    import NimbleParsec
    import __MODULE__.ParserHelpers

    rule =
      bag()
      |> ignore(whitespace() |> string("contain") |> concat(whitespace()))
      |> concat(
        choice([
          bags(
            integer(min: 1)
            |> ignore(ascii_string([?\s], min: 1))
            |> concat(bag())
            |> wrap()
            |> map({List, :to_tuple, []})
          ),
          ignore(string("no other bags"))
        ])
        |> tag(:contain)
      )
      |> ignore(ascii_string([?., ?\n], min: 1))
      |> eos()

    defparsec(:parse, rule)
  end

  defmodule RuleGraph do
    def from_tokens(tokens) do
      IO.inspect tokens
      Enum.into(tokens, %{}, fn
        {:ok, [bag: [modifier: mod, color: color], contain: bags], "", _, _, _} ->
          {{mod, color}, bags}

          # otherwise, raise
      end)
      |> build()
    end

    def build(rules) do
      {edges, graph} =
        Enum.map_reduce(rules, :digraph.new(), fn
          {key, value}, graph ->
            _ew_side_effects! = :digraph.add_vertex(graph, key)

            edges =
              for {quantity, {:bag, [modifier: mod, color: color]}} <- value do
                {key, {mod, color}, quantity}
              end

            {edges, graph}
        end)

      _side_effects =
        for {v1, v2, quantity} <- List.flatten(edges) do
          :digraph.add_edge(graph, v1, v2, quantity)
        end

      {:ok, graph}
    end

    @doc """
    List the bags a given bag fits in according to the rules
    """
    def fits_in(graph, haystack, acc \\ [])

    def fits_in(_graph, [], acc), do: acc

    def fits_in(graph, [_vertex | _] = in_neighbours, acc) do
      to_visit = in_neighbours -- acc
      Enum.reduce(to_visit, acc ++ to_visit, &fits_in(graph, &1, &2))
    end

    def fits_in(graph, {_, _} = vertex, acc) do
      neighbours = :digraph.in_neighbours(graph, vertex)
      fits_in(graph, neighbours, acc)
    end
  end
end
