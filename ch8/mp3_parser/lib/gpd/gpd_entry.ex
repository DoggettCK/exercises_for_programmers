defmodule GpdEntry do
  defstruct id: nil, namespace: nil, offset: nil, length: nil 

  def parse_entry_table(data, count), do: parse_entry_table(data, count, [])

  defp parse_entry_table(_, 0, entries), do: entries |> Enum.reverse
  defp parse_entry_table(data, count, entries) do
    <<ns::unsigned-integer-size(16), id::unsigned-integer-size(64), offset::unsigned-integer-size(32), len::unsigned-integer-size(32), remaining::binary>> = data

    parse_entry_table(remaining, count - 1, [%GpdEntry{id: id, namespace: ns, offset: offset, length: len} | entries])
  end
end

