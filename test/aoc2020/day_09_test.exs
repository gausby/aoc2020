defmodule Aoc2020.Day09Test do
  use ExUnit.Case
  doctest Aoc2020.Day09

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_09"])

  setup_all do
    numbers =
      for line <- File.stream!(Path.join(@data_dir, "input")),
          {number, _new_line} = Integer.parse(line) do
        number
      end

    {:ok, numbers: numbers}
  end

  describe "part one" do
    test "example" do
      numbers = [
        35,
        20,
        15,
        25,
        47,
        40,
        62,
        55,
        65,
        95,
        102,
        117,
        150,
        182,
        127,
        219,
        299,
        277,
        309,
        576
      ]

      assert {:error, {:invalid, 127}} == checksum(numbers, 5)
    end

    test "actual data", %{numbers: numbers} do
      assert {:error, {:invalid, 90_433_990}} == checksum(numbers, 25)
    end

    defp checksum([_ | remaining] = list, preample_length) do
      {preample, [number | _]} = Enum.split(list, preample_length)

      case do_checksum(preample, number) do
        :ok ->
          checksum(remaining, preample_length)

        {:error, {:invalid, _n}} = error ->
          error
      end
    end

    defp do_checksum([_], number), do: {:error, {:invalid, number}}

    defp do_checksum([x | [_ | _] = rest], number) do
      case Enum.drop_while(rest, fn y -> x + y != number end) do
        [] ->
          do_checksum(rest, number)

        [_match | _] ->
          :ok
      end
    end
  end

  describe "part two" do
    test "example data" do
      numbers = [
        35,
        20,
        15,
        25,
        47,
        40,
        62,
        55,
        65,
        95,
        102,
        117,
        150,
        182,
        127,
        219,
        299,
        277,
        309,
        576
      ]

      assert {:ok, window} = scan_for_window(numbers, _target = 127)
      result = Enum.sort(window)
      {lower, upper} = {List.first(result), List.last(result)}
      assert 62 == lower + upper
    end

    test "actual data", %{numbers: numbers} do
      assert {:ok, window} = scan_for_window(numbers, _target = 90_433_990)
      result = Enum.sort(window)
      {lower, upper} = {List.first(result), List.last(result)}
      assert 11_691_646 == lower + upper
    end

    defp scan_for_window(numbers, target) do
      initial_state = {:queue.new(), 0, target}

      case Enum.reduce_while(numbers, initial_state, &do_scan/2) do
        {:ok, [_ | _]} = success -> success
        {_window, _sum, _target} -> {:error, :not_found}
      end
    end

    defp do_scan(value, {window, sum, target}) do
      case value do
        _target_found when target == value + sum ->
          result = :queue.to_list(:queue.in(value, window))
          {:halt, {:ok, result}}

        _grow_window when target > value + sum ->
          window = :queue.in(value, window)
          {:cont, {window, sum + value, target}}

        _shrink_window_and_retry_value when target < value + sum ->
          {{:value, leaving}, window} = :queue.out(window)
          do_scan(value, {window, sum - leaving, target})
      end
    end
  end
end
