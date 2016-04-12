defmodule GpdFreeSpace do
  defstruct offset: nil, length: nil

  def parse_free_space_table(data, count), do: parse_free_space_table(data, count, [])

  defp parse_free_space_table(_, 0, entries), do: entries |> Enum.reverse
  defp parse_free_space_table(data, count, entries) do
    <<offset::unsigned-integer-size(32), len::unsigned-integer-size(32), remaining::binary>> = data

    parse_free_space_table(remaining, count - 1, [%GpdFreeSpace{offset: offset, length: len} | entries])
  end
end

