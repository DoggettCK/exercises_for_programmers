defmodule GpdSyncData do
  defstruct next_sync_id: nil, last_synced_id: nil, last_synced_time: nil

  def parse(data) do
    <<next_sync_id::unsigned-integer-size(64), last_synced_id::unsigned-integer-size(64), last_synced_time::unsigned-integer-size(64)>> = data

    %GpdSyncData{
      next_sync_id: next_sync_id,
      last_synced_id: last_synced_id,
      last_synced_time: last_synced_time |> TimeUtils.filetime_to_datetime
    }
  end
end
