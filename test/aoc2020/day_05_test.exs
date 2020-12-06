defmodule Aoc2020.Day05Test do
  use ExUnit.Case
  doctest Aoc2020.Day05

  alias Aoc2020.Day05.BoardingPass

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_05"])

  setup_all do
    bording_passes =
      Path.join(@data_dir, "input")
      |> File.stream!()
      |> Enum.map(&BoardingPass.parse/1)

    {:ok, bording_passes: bording_passes}
  end

  test "part one", %{bording_passes: boarding_passes} do
    # what is the higest seat id of all the boarding passes ?
    higest_seat_id = Enum.reduce(boarding_passes, 0, &max(&1.id, &2))

    assert higest_seat_id == 883
  end

  test "part two", %{bording_passes: boarding_passes} do
    # Brute-force the rows, group them together by their row number,
    # and find the one row that only has seven seats taken; it is a
    # full flight, and we know that the row we are interested in has
    # eight seats (there are some rows in the back and in the front
    # that doesn't have eight seats); thus we will look for the one
    # row that has one seat missing.
    [{row, row_boarding_passes}] =
      boarding_passes
      |> Enum.group_by(& &1.row)
      |> Enum.filter(&match?({_row, taken} when length(taken) == 7, &1))

    # The column we can find by summing the column numbers of a full
    # column, and then subtracting the known column numbers, leaving
    # the column number of the one free seat
    column =
      Enum.reduce(
        row_boarding_passes,
        _full_column_total_sum = 7 + 6 + 5 + 4 + 3 + 2 + 1,
        &(&2 - &1.column)
      )

    # spoiler alert!
    assert 532 == row * 8 + column
  end
end
