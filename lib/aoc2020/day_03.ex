defmodule Aoc2020.Day03 do
  @moduledoc """
  Day 3: Toboggan Trajectory

  ## Part One

  With the toboggan login problems resolved, you set off toward the
  airport. While travel by toboggan might be easy, it's certainly not
  safe: there's very minimal steering and the area is covered in
  trees. You'll need to see which angles will take you near the fewest
  trees.

  Due to the local geology, trees in this area only grow on exact
  integer coordinates in a grid. You make a map (your puzzle input) of
  the open squares (.) and trees (#) you can see. For example:

  ..##.......
  #...#...#..
  .#....#..#.
  ..#.#...#.#
  .#...##..#.
  ..#.##.....
  .#.#.#....#
  .#........#
  #.##...#...
  #...##....#
  .#..#...#.#

  These aren't the only trees, though; due to something you read about
  once involving arboreal genetics and biome stability, the same
  pattern repeats to the right many times:

  ..##.........##.........##.........##.........##.........##.......  --->
  #...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
  .#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
  ..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
  .#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
  ..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
  .#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
  .#........#.#........#.#........#.#........#.#........#.#........#
  #.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
  #...##....##...##....##...##....##...##....##...##....##...##....#
  .#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

  You start on the open square (.) in the top-left corner and need to
  reach the bottom (below the bottom-most row on your map).

  The toboggan can only follow a few specific slopes (you opted for a
  cheaper model that prefers rational numbers); start by counting all
  the trees you would encounter for the slope right 3, down 1:

  From your starting position at the top-left, check the position that
  is right 3 and down 1. Then, check the position that is right 3 and
  down 1 from there, and so on until you go past the bottom of the
  map.

  The locations you'd check in the above example are marked here with
  O where there was an open square and X where there was a tree:

  ..##.........##.........##.........##.........##.........##.......  --->
  #..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
  .#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
  ..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
  .#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
  ..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
  .#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
  .#........#.#........X.#........#.#........#.#........#.#........#
  #.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
  #...##....##...##....##...#X....##...##....##...##....##...##....#
  .#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

  In this example, traversing the map using this slope would cause you
  to encounter 7 trees.

  Starting at the top-left corner of your map and following a slope of
  right 3 and down 1, how many trees would you encounter?

  ## Part Two

  ...
  """

  defmodule Terrain do
    defstruct rows: %{}, cursors: %{}

    defmodule OutOfBounds do
      defexception [:message]
    end

    use Bitwise

    alias __MODULE__

    @doc """
    Create a new terrain with the given `map_data`
    """
    def new(map_data) do
      %{} = rows = decode(map_data)
      %Terrain{rows: rows}
    end

    @doc """
    Add a cursor to the terrain session

    The cursor can be moved via actions, and it can make an
    observation. The observations can later be collected.
    """
    def add_cursor(%Terrain{} = t, cursor) when is_atom(cursor) do
      add_cursor(t, {cursor, []})
    end

    def add_cursor(%Terrain{cursors: cursors} = t, {cursor, opts}) when is_atom(cursor) do
      x = Keyword.get(opts, :x, 0)
      y = Keyword.get(opts, :y, 0)
      %Terrain{t | cursors: Map.put_new(cursors, cursor, {{x, y}, []})}
    end

    @doc """
    Check if there is a tree at the coordinate, or cursor position
    """
    def tree?(%Terrain{rows: rows}, {_x, y}) when y > map_size(rows) or y < 0 do
      raise OutOfBounds, "Out of bounds"
    end

    def tree?(%Terrain{rows: rows}, {x, y}) do
      line = Map.fetch!(rows, y)
      len = bit_size(line)
      # Make a mask for the poisition in the bit string, looping
      # around on the boundaries.
      local_pos = rem(x, len) + 1
      mask = 1 <<< (len - local_pos)
      <<value::integer-size(len)>> = line

      # Check the mask (it will be true if there is a hit)
      band(mask, value) == mask
    end

    def tree?(%Terrain{cursors: cursors} = t, cursor) when is_atom(cursor) do
      {position, _observations} = Map.fetch!(cursors, cursor)
      tree?(t, position)
    end

    @doc """
    Collect the observations for the given `cursor`
    """
    def collect(%Terrain{cursors: cursors}, cursor) when is_atom(cursor) do
      {_position, observations} = Map.fetch!(cursors, cursor)
      Enum.reverse(observations)
    end

    @doc """
    Specify one or more actions for the given `cursor`
    """
    def action(%Terrain{cursors: cursors}, cursor, _)
        when not is_map_key(cursors, cursor),
        do: raise(ArgumentError, "Unknown cursor: #{inspect(cursor)}")

    def action(%Terrain{} = t, _cursor, []), do: t

    def action(%Terrain{} = t, cursor, moves) when is_list(moves) do
      Enum.reduce(moves, t, &action(&2, cursor, &1))
    end

    def action(%Terrain{} = t, _cursor, {:repeat, []}), do: t

    def action(%Terrain{} = t, cursor, {:repeat, actions}) when is_list(actions) do
      # Repeat until we are out of bounds
      try do
        t
        |> action(cursor, actions)
        |> action(cursor, {:repeat, actions})
      rescue
        OutOfBounds -> t
      end
    end

    def action(%Terrain{cursors: cursors} = t, cursor, :observe) do
      %Terrain{
        t
        | cursors:
            Map.update!(cursors, cursor, fn {pos, observations} ->
              {pos, [{pos, tree?(t, pos)} | observations]}
            end)
      }
    end

    def action(%Terrain{} = t, cursor, {direction, amount}) when is_integer(amount) do
      {dx, dy} =
        case direction do
          :left -> {amount * -1, 0}
          :right -> {amount, 0}
          :up -> {0, amount * -1}
          :down -> {0, amount * 1}
          other -> raise ArgumentError, "Unknown action #{inspect(other)}"
        end

      update_cursor_pos(t, cursor, {dx, dy})
    end

    def action(t, cursor, direction) when is_atom(direction),
      do: action(t, cursor, {direction, 1})

    # Update the cursor with out of bounds checks
    defp update_cursor_pos(%Terrain{cursors: cursors}, cursor, _)
         when not is_map_key(cursors, cursor) do
      raise ArgumentError, "Unknown cursor: #{inspect(cursor)}"
    end

    defp update_cursor_pos(%Terrain{rows: rows} = t, cursor, {dx, dy}) do
      %Terrain{
        t
        | cursors:
            Map.update!(t.cursors, cursor, fn
              {{_x, y}, _observations} when y < 0 or y + dy >= map_size(rows) ->
                raise OutOfBounds, "Out of bounds"

              {{x, y}, observations} ->
                {{x + dx, y + dy}, observations}
            end)
      }
    end

    @doc """
    Decode a map from ascii representation
    """
    def decode(%File.Stream{} = stream) do
      stream
      |> Stream.map(&decode_line(&1))
      |> Stream.with_index()
      |> Enum.into(%{}, fn {a, b} -> {b, a} end)
    end

    defp decode_line(""), do: raise(ArgumentError, "Line cannot be empty")

    defp decode_line(line) do
      line = String.trim(line)
      len = byte_size(line)

      value =
        String.replace(line, [".", "#"], fn
          "#" -> "1"
          "." -> "0"
        end)
        |> String.to_integer(2)

      <<value::integer-size(len)>>
    end

    @doc """
    Encode data into ascii
    """
    def encode(data) do
      for line <- data, into: <<>> do
        encode_line(line) <> "\n"
      end
    end

    defp encode_line(map_row) do
      for <<pos::1 <- map_row>>, into: <<>> do
        case pos do
          0 -> "."
          1 -> "#"
        end
      end
    end
  end

  # is it the end already ?
end
