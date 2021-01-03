defmodule Aoc2020.Day11 do
  @moduledoc """
  Day 11: Seating System

  ## Part One

  Your plane lands with plenty of time to spare. The final leg of your
  journey is a ferry that goes directly to the tropical island where
  you can finally start your vacation. As you reach the waiting area
  to board the ferry, you realize you're so early, nobody else has
  even arrived yet!

  By modeling the process people use to choose (or abandon) their seat
  in the waiting area, you're pretty sure you can predict the best
  place to sit. You make a quick map of the seat layout (your puzzle
  input).

  The seat layout fits neatly on a grid. Each position is either floor
  (.), an empty seat (L), or an occupied seat (#). For example, the
  initial seat layout might look like this:

      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL

  Now, you just need to model the people who will be arriving
  shortly. Fortunately, people are entirely predictable and always
  follow a simple set of rules. All decisions are based on the number
  of occupied seats adjacent to a given seat (one of the eight
  positions immediately up, down, left, right, or diagonal from the
  seat). The following rules are applied to every seat simultaneously:

  - If a seat is empty (L) and there are no occupied seats adjacent to
    it, the seat becomes occupied.

  - If a seat is occupied (#) and four or more seats adjacent to it
    are also occupied, the seat becomes empty.

  - Otherwise, the seat's state does not change.

  Floor (.) never changes; seats don't move, and nobody sits on the
  floor.

  After one round of these rules, every seat in the example layout
  becomes occupied:

      #.##.##.##
      #######.##
      #.#.#..#..
      ####.##.##
      #.##.##.##
      #.#####.##
      ..#.#.....
      ##########
      #.######.#
      #.#####.##

  After a second round, the seats with four or more occupied adjacent
  seats become empty again:

      #.LL.L#.##
      #LLLLLL.L#
      L.L.L..L..
      #LLL.LL.L#
      #.LL.LL.LL
      #.LLLL#.##
      ..L.L.....
      #LLLLLLLL#
      #.LLLLLL.L
      #.#LLLL.##

  This process continues for three more rounds:

      #.##.L#.##
      #L###LL.L#
      L.#.#..#..
      #L##.##.L#
      #.##.LL.LL
      #.###L#.##
      ..#.#.....
      #L######L#
      #.LL###L.L
      #.#L###.##

      #.#L.L#.##
      #LLL#LL.L#
      L.L.L..#..
      #LLL.##.L#
      #.LL.LL.LL
      #.LL#L#.##
      ..L.L.....
      #L#LLLL#L#
      #.LLLLLL.L
      #.#L#L#.##

      #.#L.L#.##
      #LLL#LL.L#
      L.#.L..#..
      #L##.##.L#
      #.#L.LL.LL
      #.#L#L#.##
      ..L.L.....
      #L#L##L#L#
      #.LLLLLL.L
      #.#L#L#.##

  At this point, something interesting happens: the chaos stabilizes
  and further applications of these rules cause no seats to change
  state! Once people stop moving around, you count 37 occupied seats.

  Simulate your seating area by applying the seating rules repeatedly
  until no seats change state. How many seats end up occupied?

  ## Part Two

  ...
  """

  defmodule Seating do
    import Bitwise

    defstruct seats: 0, occupied: 0, floor_mask: 0, layout: {0, 0}

    def new(<<layout::binary>>) do
      decode(layout)
    end

    def decode(layout, pos \\ 0, acc \\ {nil, 0, 0})

    def decode(<<>>, pos, {wall, floor, seats}) do
      # sanity check, the floor and seat mask should share no seats
      true = band(seats, floor) == 0

      column_width = wall
      row_width = div(pos, wall)

      %__MODULE__{layout: {column_width, row_width}, seats: seats, floor_mask: floor}
    end

    def decode(<<head::binary-size(1), remaining::binary>>, pos, {wall, floor, seats}) do
      case head do
        "L" ->
          floor = floor * 2 + 0
          seats = seats * 2 + 1
          decode(remaining, pos + 1, {wall, floor, seats})

        "." ->
          floor = floor * 2 + 1
          seats = seats * 2 + 0
          decode(remaining, pos + 1, {wall, floor, seats})

        "\n" when wall == nil ->
          wall = pos
          floor = floor * 2 + 0
          seats = seats * 2 + 0
          decode(remaining, pos, {wall, floor, seats})

        "\n" when wall > 0 and rem(pos, wall) == 0 ->
          floor = floor * 2 + 0
          seats = seats * 2 + 0
          decode(remaining, pos, {wall, floor, seats})
      end
    end

    def step(seating, fuel \\ 1)

    def step(%__MODULE__{} = seating, 0), do: seating

    def step(%__MODULE__{layout: {columns, rows}} = seating, fuel) when fuel > 0 do
      length_with_wall = columns + 1
      grid_area = length_with_wall * rows

      w = length_with_wall - 3
      cursor_size = 2 * w + 9

      <<cursor_value::integer-size(cursor_size)>> =
        <<0b111::3, 0::size(w), 0b101::3, 0::size(w), 0b111::3>>

      # position our cursor mask
      initial_cursor = cursor_value <<< (grid_area - 2)

      # add padding, making it easier to use our seating mask
      padded_seats = seating.seats <<< length_with_wall
      padded_occ = seating.occupied <<< length_with_wall

      occupied = do_step({columns, rows}, padded_seats, padded_occ, initial_cursor)

      step(%__MODULE__{seating | occupied: occupied}, fuel - 1)
    end

    defp do_step({c, r}, seats, occupied, cursor) do
      lars_size = (c + 1) * (r + 1)

      {_, _, acc} =
        for <<(bit::1 <- <<seats::integer-size(lars_size)>>)>>,
          reduce: {cursor, 1 <<< (lars_size - 1), 0} do
          {cursor, index, acc} when bit == 1 ->
            adjacents = count_enabled_bits(band(cursor, occupied))

            case _occupied? = band(index, occupied) == index do
              # - If a seat is empty (L) and there are no occupied
              #   seats adjacent to it, the seat becomes occupied.
              false when adjacents == 0 ->
                {cursor >>> 1, index >>> 1, acc * 2 + 1}

              # - If a seat is occupied (#) and four or more seats
              #   adjacent to it are also occupied, the seat becomes
              #   empty.
              true when adjacents >= 4 ->
                {cursor >>> 1, index >>> 1, acc * 2 + 0}

              # - Otherwise, the seat's state does not change.
              true ->
                {cursor >>> 1, index >>> 1, acc * 2 + 1}

              false ->
                {cursor >>> 1, index >>> 1, acc * 2 + 0}
            end

          {cursor, index, acc} when bit == 0 ->
            {cursor >>> 1, index >>> 1, acc * 2 + 0}
        end

      acc >>> (c + 1)
    end

    defp count_enabled_bits(n, acc \\ 0)

    defp count_enabled_bits(0, acc), do: acc

    defp count_enabled_bits(n, acc) do
      count_enabled_bits(band(n, n - 1), acc + 1)
    end

    def seats(%__MODULE__{seats: n}) do
      count_enabled_bits(n)
    end

    def occupied(%__MODULE__{occupied: n}) do
      count_enabled_bits(n)
    end

    def to_string(%__MODULE__{} = seating) do
      IO.iodata_to_binary(to_list(seating))
    end

    def to_list(%__MODULE__{layout: {columns, rows}} = seating) do
      masked_seats = band(seating.seats, bnot(seating.floor_mask))
      length_with_wall = columns + 1
      grid_area = length_with_wall * rows
      bits = <<masked_seats::integer-size(grid_area)>>

      {_, acc} =
        for <<bit::1 <- bits>>,
          reduce: {_pos = 0, _io_list = []} do
          # skip walls in output
          {pos, acc} when rem(pos + 1, length_with_wall) == 0 ->
            {pos + 1, ["\n" | acc]}

          {pos, acc} when bit == 1 ->
            # this is a seat, check if occupied, and print "#",
            # otherwise print "L"
            if active?(seating.occupied, grid_area - pos - 1) do
              {pos + 1, ["#" | acc]}
            else
              {pos + 1, ["L" | acc]}
            end

          {pos, acc} when bit == 0 ->
            {pos + 1, ["." | acc]}
        end

      Enum.reverse(acc)
    end

    defp active?(state, pos) do
      mask = 1 <<< pos
      band(state, mask) == mask
    end

    defimpl Enumerable do
      alias Aoc2020.Day11.Seating

      def count(%Seating{} = seating) do
        Seating.seats(seating)
      end

      def reduce(_state, {:halt, acc}, _fun), do: {:halted, acc}

      def reduce(state, {:suspend, acc}, fun),
        do: {:suspended, acc, &reduce(state, &1, fun)}

      def reduce(%Seating{} = state, {:cont, acc}, fun) do
        state = Seating.step(state)
        reduce(state, fun.(state, acc), fun)
      end

      def reduce(%Seating{}, {:cont, acc}, _fun),
        do: {:done, acc}

      def slice(%Seating{}) do
        {:error, __MODULE__}
      end

      def member?(%Seating{}, _) do
        {:error, __MODULE__}
      end
    end

    defimpl Inspect do
      import Inspect.Algebra

      alias Aoc2020.Day11.Seating

      def inspect(seating, opts) do
        # todo, make the formatting prettier
        concat(["#Seating<", to_doc(Seating.to_list(seating), opts), ">"])
      end
    end
  end
end
