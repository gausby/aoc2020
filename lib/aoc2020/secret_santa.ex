defmodule Aoc2020.SecretSanta do
  def pair_participants([]), do: {:error, :no_participants}
  def pair_participants([_]), do: {:error, :not_enough_participants}

  def pair_participants([_ | _] = participants) do
    [first | rest] = participants = Enum.shuffle(participants)

    result = Enum.zip(participants, rest ++ [first])
    {:ok, Enum.into(result, %{})}
  end
end
