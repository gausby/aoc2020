defmodule Aoc2020.SecretSantaTest do
  # Here's your proptest, @davydog187 !
  # https://twitter.com/davydog187/status/1333806778530795521

  use ExUnit.Case
  use ExUnitProperties
  doctest Aoc2020.SecretSanta

  alias Aoc2020.SecretSanta

  property "no participants should get paired with themselves" do
    check all(input_list <- uniq_list_of(string(:printable), min_length: 2)) do
      assert {:ok, result} = SecretSanta.pair_participants(input_list)
      refute Enum.any?(result, &match?({same, same}, &1))
    end
  end
end
