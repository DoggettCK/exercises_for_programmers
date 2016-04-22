defmodule GpdSyncEntry do
  defstruct entry_id: nil, sync_id: nil

  def parse_sync_list(sync_list_data), do: parse_sync_list(sync_list_data, [])
  defp parse_sync_list(<<>>, results), do: results |> Enum.reverse
  defp parse_sync_list(<<entry_id::unsigned-integer-size(64), sync_id::unsigned-integer-size(64), rest::binary>>, results) do
    parse_sync_list(rest, [%GpdSyncEntry{entry_id: entry_id, sync_id: sync_id} | results])
  end

  defimpl Inspect, for: GpdSyncEntry do
    import Inspect.Algebra

    def inspect(%GpdSyncEntry{} = entry, _opts) do
      concat ["#GpdSyncEntry<",
        "#{GpdConstants.setting_name(entry.entry_id)} (0x#{entry.entry_id |> Integer.to_string(16)})",
        "\tSync ID: #{entry.sync_id}",
        ">"]
    end
  end
end
