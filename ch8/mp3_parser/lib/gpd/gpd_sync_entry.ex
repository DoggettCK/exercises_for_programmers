defmodule GpdSyncEntry do
  defstruct entry_id: nil, sync_id: nil

  def parse_sync_list(sync_list_data), do: parse_sync_list(sync_list_data, [])
  defp parse_sync_list(<<>>, results), do: results |> Enum.reverse
  defp parse_sync_list(<<entry_id::unsigned-integer-size(64), sync_id::unsigned-integer-size(64), rest::binary>>, results) do
    parse_sync_list(rest, [%GpdSyncEntry{entry_id: entry_id, sync_id: sync_id} | results])
  end
end
