defmodule GpdSettingEntry do
  defstruct id: nil, last_edited: nil, unknown: nil, data_type: nil, data: nil, remaining: nil

  @data_types %{
    context: 0,
    int32: 1,
    int64: 2,
    double: 3,
    unicode_string: 4,
    float: 5,
    binary: 6,
    datetime: 7,
    null: 0xFF
  }

  for {key, value} <- @data_types do
    def data_type(unquote(value)), do: unquote(key)
  end

  def parse_setting(data) do
    <<id::signed-integer-size(32),
    last_edited::unsigned-integer-size(16),
    unknown::unsigned-integer-size(16),
    type::unsigned-integer-size(8),
    _::binary-size(7),
    remaining::binary>> = data

    %GpdSettingEntry{
      id: id,
      last_edited: last_edited,
      unknown: unknown,
      data_type: data_type(type),
      data: parse_data_by_type(remaining, data_type(type))
    }
  end

  defp parse_data_by_type(<<int32::unsigned-integer-size(32), _::binary>>, :int32), do: int32
  defp parse_data_by_type(<<int64::unsigned-integer-size(64), _::binary>>, :int64), do: int64
  defp parse_data_by_type(<<float::unsigned-float-size(64), _::binary>>, :float), do: float
  defp parse_data_by_type(<<double::unsigned-float-size(64), _::binary>>, :double), do: double
  defp parse_data_by_type(<<len::unsigned-integer-size(32), 0::unsigned-integer-size(32), str::binary-size(len)>>, :unicode_string) do
    GpdStringUtils.split_null_terminated(str, 1) |> hd
  end
  defp parse_data_by_type(<<filetime::unsigned-integer-size(64)>>, :datetime), do: filetime |> TimeUtils.to_human_readable
  defp parse_data_by_type(data, _), do: data

  for id <- [:sync_list] |> Enum.map(&GpdConstants.setting_id/1) do
    def parse_entry(%GpdEntry{id: unquote(id), length: len}, %Gpd{remaining_data: data} = gpd) do
      << entry_data::binary-size(len), remaining_data::binary >> = data

      %Gpd{ gpd | setting_sync_list: GpdSyncEntry.parse_sync_list(entry_data), remaining_data: remaining_data }
    end
  end

  for id <- [:sync_data] |> Enum.map(&GpdConstants.setting_id/1) do
    def parse_entry(%GpdEntry{id: unquote(id), length: len}, %Gpd{remaining_data: data} = gpd) do
      << entry_data::binary-size(len), remaining_data::binary >> = data

      %Gpd{ gpd | setting_sync_data: GpdSyncData.parse(entry_data), remaining_data: remaining_data }
    end
  end
  
  for id <- [:title_specific1, :title_specific2, :title_specific3] |> Enum.map(&GpdConstants.setting_id/1) do
    def parse_entry(%GpdEntry{id: unquote(id), length: len}, %Gpd{remaining_data: data} = gpd) do
      << entry_data::binary-size(len), remaining_data::binary >> = data

      %Gpd{ gpd | settings: [GpdBinarySettingEntry.parse(unquote(id), entry_data) | gpd.settings], remaining_data: remaining_data }
    end
  end

  def parse_entry(%GpdEntry{length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | settings: [parse_setting(entry_data) | gpd.settings], remaining_data: remaining_data }
  end

  defimpl Inspect, for: GpdSettingEntry do
    import Inspect.Algebra

    def inspect(%GpdSettingEntry{} = entry, _opts) do
      concat ["#GpdSettingEntry<",
        "#{GpdConstants.setting_name(entry.id)} (0x#{entry.id})",
        "\tData: #{inspect_data(entry.data_type, entry.data)}",
        "\tLast Edited: #{entry.last_edited |> TimeUtils.to_human_readable}",
        ">"]
    end

    defp inspect_data(data_type, data) when data_type in [:int32, :int64, :double, :unicode_string, :float, :datetime], do: "(#{data_type}) #{data}"
    defp inspect_data(:binary, data), do: "(#{:binary}) #{Base.encode16(data)}"
    defp inspect_data(_, data), do: "(unknown) #{Base.encode16(data)}"
  end
end
