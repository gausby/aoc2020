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
    test "example" do
      adapters = [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4]
      assert %{1 => 7, 3 => 5} == adapter_frequencies(adapters)
    end

    test "actual data", %{adapters: adapters} do
      assert %{1 => 64 = one_jolts, 3 => 32 = three_jolts} = adapter_frequencies(adapters)
      assert 2048 == one_jolts * three_jolts
    end

    defp adapter_frequencies(adapters) do
      # the outlet is always 0 jolts
      adapters = Enum.sort([_outlet = 0 | adapters], :desc)
      # the built in adapter is always rated 3 jolts more than the final adapter 
      built_in_adapter = hd(adapters) + 3

      {distribution, _} =
        Enum.map_reduce(adapters, built_in_adapter, fn
          adapter, previous_adapter -> {previous_adapter - adapter, adapter}
        end)

      Enum.frequencies(distribution)
    end
  end

  describe "part two" do
    @tag skip: true
    test "example data"

    @tag skip: true
    test "actual data"
  end
end
