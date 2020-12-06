defmodule Aoc2020.Day05Test do
  use ExUnit.Case
  doctest Aoc2020.Day05

  alias Aoc2020.Day05
  alias Aoc2020.Day05.BoardingPass

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_05"])

  setup_all do
    bording_pass_stream = File.stream!(Path.join(@data_dir, "input"))
    {:ok, bording_passes: bording_pass_stream}
  end

  test "part one", %{bording_passes: boarding_passes} do
    # what is the higest seat id of all the boarding passes ?
    higest_seat_id =
      for boarding_pass <- boarding_passes,
          %BoardingPass{id: id} = BoardingPass.parse(boarding_pass),
          reduce: 0 do
        acc -> max(id, acc)
      end

    assert higest_seat_id == 883
  end

  test "part two"
end
