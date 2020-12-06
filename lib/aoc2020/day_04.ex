defmodule Aoc2020.Day04 do
  @moduledoc """
  Day 3: Passport Processing

  ## Part One

  You arrive at the airport only to realize that you grabbed your
  North Pole Credentials instead of your passport. While these
  documents are extremely similar, North Pole Credentials aren't
  issued by a country and therefore aren't actually valid
  documentation for travel in most of the world.

  It seems like you're not the only one having problems, though; a
  very long line has formed for the automatic passport scanners, and
  the delay could upset your travel itinerary.

  Due to some questionable network security, you realize you might be
  able to solve both of these problems at the same time.

  The automatic passport scanners are slow because they're having
  trouble detecting which passports have all required fields. The
  expected fields are as follows:

  - byr (Birth Year)
  - iyr (Issue Year)
  - eyr (Expiration Year)
  - hgt (Height)
  - hcl (Hair Color)
  - ecl (Eye Color)
  - pid (Passport ID)
  - cid (Country ID)

  Passport data is validated in batch files (your puzzle input). Each
  passport is represented as a sequence of key:value pairs separated
  by spaces or newlines. Passports are separated by blank lines.

  Here is an example batch file containing four passports:

    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in

  The first passport is valid - all eight fields are present. The
  second passport is invalid - it is missing hgt (the Height field).

  The third passport is interesting; the only missing field is cid, so
  it looks like data from North Pole Credentials, not a passport at
  all! Surely, nobody would mind if you made the system temporarily
  ignore missing cid fields. Treat this "passport" as valid.

  The fourth passport is missing two fields, cid and byr. Missing cid
  is fine, but missing any other field is not, so this passport is
  invalid.

  According to the above rules, your improved system would report 2
  valid passports.

  Count the number of valid passports - those that have all required
  fields. Treat cid as optional. In your batch file, how many
  passports are valid?

  ## Part Two

  The line is moving more quickly now, but you overhear airport
  security talking about how passports with invalid data are getting
  through. Better add some data validation, quick!

  You can continue to ignore the cid field, but each other field has
  strict rules about what values are valid for automatic validation:

  - byr (Birth Year) - four digits; at least 1920 and at most 2002.
  - iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  - eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  - hgt (Height) - a number followed by either cm or in:
    - If cm, the number must be at least 150 and at most 193.
    - If in, the number must be at least 59 and at most 76.
  - hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  - ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  - pid (Passport ID) - a nine-digit number, including leading zeroes.
  - cid (Country ID) - ignored, missing or not.

  Your job is to count the passports where all required fields are
  both present and valid according to the above rules. Here are some
  example values:

    byr valid:   2002
    byr invalid: 2003

    hgt valid:   60in
    hgt valid:   190cm
    hgt invalid: 190in
    hgt invalid: 190

    hcl valid:   #123abc
    hcl invalid: #123abz
    hcl invalid: 123abc

    ecl valid:   brn
    ecl invalid: wat

    pid valid:   000000001
    pid invalid: 0123456789
    Here are some invalid passports:

    eyr:1972 cid:100
    hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

    iyr:2019
    hcl:#602927 eyr:1967 hgt:170cm
    ecl:grn pid:012533040 byr:1946

    hcl:dab227 iyr:2012
    ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

    hgt:59cm ecl:zzz
    eyr:2038 hcl:74454a iyr:2023
    pid:3556412378 byr:2007

  Here are some valid passports:

    pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
    hcl:#623a2f

    eyr:2029 ecl:blu cid:129 byr:1989
    iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

    hcl:#888785
    hgt:164cm byr:2001 iyr:2015 cid:88
    pid:545766238 ecl:hzl
    eyr:2022

    iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719

  Count the number of valid passports - those that have all required
  fields and valid values. Continue to treat cid as optional. In your
  batch file, how many passports are valid?
  """

  defmodule Document do
    @fields [
      :birth_year,
      :issue_year,
      :expiration_year,
      :height,
      :hair_color,
      :eye_color,
      :passport_id,
      :country_id
    ]

    defstruct [{:issues, []} | @fields]

    def north_pole_credentials?(%Document{} = document),
      do: valid?(document, ignore: [:country_id])

    def passport?(%Document{} = document),
      do: valid?(document, [])

    def valid?(%Document{} = document, opts \\ []) do
      inspect = Keyword.get(opts, :inspect, @fields)
      ignore = Keyword.get(opts, :ignore, [])
      fields = inspect -- ignore

      Enum.all?(fields, &(not is_nil(Map.fetch!(document, &1))))
    end

    def validate(%Document{} = document, opts \\ []) do
      inspect = Keyword.get(opts, :inspect, @fields)
      ignore = Keyword.get(opts, :ignore, [])
      fields = inspect -- ignore

      Enum.reduce(fields, %{document | issues: []}, &validate_/2)
    end

    defp validate_(:birth_year, %{birth_year: year} = doc)
         when year in 1920..2002 do
      doc
    end

    defp validate_(:issue_year, %{issue_year: year} = doc)
         when year in 2010..2020 do
      doc
    end

    defp validate_(:expiration_year, %{expiration_year: year} = doc)
         when year in 2020..2030 do
      doc
    end

    defp validate_(:height, %{height: {height, "cm"}} = doc)
         when height in 150..193 do
      # not too short, not the tall!!
      doc
    end

    defp validate_(:height, %{height: {height, "in"}} = doc)
         when height in 59..76 do
      doc
    end

    defp validate_(:height, %{height: {input}} = doc) do
      %{doc | issues: [{:height, {:invalid, {:missing_units, input}}} | doc.issues]}
    end

    defp validate_(
           :hair_color,
           %{
             hair_color:
               <<"#", red::binary-size(2), green::binary-size(2), blue::binary-size(2)>> = input
           } = doc
         ) do
      try do
        for colour <- [red, green, blue], do: Base.decode16!(colour, case: :lower)
        doc
      rescue
        ArgumentError ->
          %{doc | issues: [{:hair_color, {:invalid, input}} | doc.issues]}
      end
    end

    defp validate_(
           :eye_color,
           %{eye_color: color} = doc
         )
         when color in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"] do
      doc
    end

    defp validate_(
           :passport_id,
           %{passport_id: <<id::binary-size(9)>>} = doc
         ) do
      try do
        # to harden it a bit we will try to see if there are any non
        # numeral numbers in the input by trying to cast it to an
        # integer--we need to store the id as a 9 digit value, padded
        # with zeros; so the best we can do is a string
        _ = String.to_integer(id)
        doc
      rescue
        ArgumentError ->
          %{doc | issues: [{:passport_id, {:invalid, id}} | doc.issues]}
      end
    end

    defp validate_(
           :country_id,
           %{country_id: id} = doc
         )
         when byte_size(id) in 1..3 do
      doc
    end

    # catch all, at this point the data is invalid
    defp validate_(field, doc) do
      case Map.fetch!(doc, field) do
        nil ->
          %{doc | issues: [{field, :missing} | doc.issues]}

        invalid_data ->
          %{doc | issues: [{field, {:invalid, invalid_data}} | doc.issues]}
      end
    end
  end

  defmodule BatchFile.Helpers do
    import NimbleParsec

    def field(name, value_name, parse_with) do
      ignore(string(value_name))
      |> ignore(string(":"))
      |> concat(parse_with)
      |> unwrap_and_tag(name)
    end
  end

  defmodule BatchFile do
    @moduledoc """

    Hi, Martin here! I guess this assignment looked like a parsec
    shaped problem, but the way the problem unfolded, especially with
    Part Two, the parsec kinda became too big of a gun. For this task
    we would like to accept any kind of data in the parser, and then
    later coerce the data into the correct values, or validate them.

    Hindsight is twenty-twenty; at least I learned a bit about
    `NimbleParsec`, which is an excelent library.
    """

    import NimbleParsec
    import __MODULE__.Helpers

    alias Aoc2020.Day04.Document

    year = integer(4)

    height =
      integer(min: 1)
      |> optional(choice([string("in"), string("cm")]))
      |> reduce({List, :to_tuple, []})

    color = ascii_string([{:not, ?\s}, {:not, ?\n}], min: 1)

    id = ascii_string([{:not, ?\s}, {:not, ?\n}], min: 1)

    data_field =
      choice([
        field(:passport_id, "pid", id),
        field(:country_id, "cid", id),
        field(:birth_year, "byr", year),
        field(:issue_year, "iyr", year),
        field(:expiration_year, "eyr", year),
        field(:height, "hgt", height),
        field(:hair_color, "hcl", color),
        field(:eye_color, "ecl", color)
      ])

    defparsecp(
      :extract,
      repeat(
        # Repeat and collect over the entries
        lookahead_not(ascii_string([?\s, ?\n], min: 0) |> eos())
        |> repeat(
          # Repeat and collect over the data fields in an entry
          lookahead_not(
            choice([
              # Stop if we are looking at two new-lines, or a new-line
              # followed by a terminator (ignoring spaces)
              ascii_string([?\s], min: 0)
              |> string("\n")
              |> ascii_string([?\s], min: 0)
              |> choice([string("\n"), eos()]),
              # and simply wrap up if we are looking at the end of line
              eos()
            ])
          )
          |> ignore(ascii_string([?\s, ?\n], min: 0))
          |> concat(data_field)
          |> ignore(ascii_string([?\s], min: 0))
        )
        |> wrap()
        |> ignore(ascii_string([?\s, ?\n], min: 0))
      )
    )

    def parse(data) do
      with {:ok, entries, "", _, _, _} <- extract(data),
           docs <- Enum.map(entries, &struct(Document, &1)),
           docs <- Enum.map(docs, &Document.validate/1) do
        {:ok, docs}
      end
    end
  end
end
