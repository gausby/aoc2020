defmodule Aoc2020Test.Day04Test do
  use ExUnit.Case
  doctest Aoc2020.Day04

  alias Aoc2020.Day04
  alias Aoc2020.Day04.Document

  @data_dir Path.join([Application.app_dir(:aoc2020), "priv", "day_04"])

  setup_all do
    # For the parser we need the new lines, so let's just read the
    # entire file instead of streaming it
    data = Path.join(@data_dir, "input") |> File.read!()
    {:ok, documents} = Day04.BatchFile.parse(data)
    {:ok, documents: documents}
  end

  test "Part one", %{documents: documents} do
    assert 204 == Enum.count(documents, &Document.north_pole_credentials?/1)
  end

  test "valid data" do
    valid_data = """
    byr:2002
    hgt:60in
    hgt:190cm
    hcl:#123abc
    ecl:brn
    pid:000000001
    """

    assert {:ok, [document]} = Day04.BatchFile.parse(valid_data)

    assert %Document{issues: []} =
             Document.validate(
               document,
               ignore: [:country_id, :expiration_year, :issue_year]
             )
  end

  test "Part two", %{documents: documents} do
    assert 179 ==
             documents
             |> Enum.map(&Document.validate(&1, ignore: [:country_id]))
             |> Enum.count(&match?(%Document{issues: []}, &1))
  end
end
