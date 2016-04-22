defmodule Gpd do
  use Bitwise

  # Entry Namespaces
  @ns_achievement 1
  @ns_image 2
  @ns_setting 3
  @ns_title 4
  @ns_string 5
  @ns_avatar_award 6

  defstruct version: nil,
  title: nil,
  entry_table_length: 0,
  entry_table_count: 0,
  free_space_table_length: 0,
  free_space_table_count: 0,
  entries: [],
  free_space: [],
  remaining_data: nil,
  achievements: [],
  images: [],
  settings: [],
  achievement_sync_data: nil,
  setting_sync_data: nil,
  achievement_sync_list: [],
  setting_sync_list: [],
  title_entries: []

  def test do
    # Remaining settings to parse for special Dashboard GPD (FFFE07D1.gpd)
    [
      "/Users/cdoggett/XBox360_20160105/Content/FFFE07D1.gpd",
    ]
    |> Enum.map(&File.read!/1)
    |> Enum.map(&Gpd.parse/1)
  end

  def parse(file_data) do
    # http://www.free60.org/wiki/GPD
    << "XDBF",
    version::unsigned-integer-size(32),
    entry_table_length::unsigned-integer-size(32),
    entry_table_count::unsigned-integer-size(32),
    free_space_table_length::unsigned-integer-size(32),
    free_space_table_count::unsigned-integer-size(32),
    remaining_data::binary>> = file_data

    %Gpd {
      version: version,
      # Length is number of entries, so multiply by entry size to get entire table
      entry_table_length: entry_table_length * 18,
      free_space_table_length: free_space_table_length * 8,
      entry_table_count: entry_table_count,
      free_space_table_count: free_space_table_count,
      remaining_data: remaining_data
    }
    |> parse_tables
    |> parse_entries
  end

  defp parse_tables(%Gpd{ entry_table_length: entry_table_length, free_space_table_length: free_space_table_length, remaining_data: data} = gpd) do
    << entries::binary-size(entry_table_length), free_space::binary-size(free_space_table_length), remaining::binary >> = data

    %Gpd{ gpd | remaining_data: remaining }
    |> parse_entry_table(entries)
    |> parse_free_space_table(free_space)
  end

  # Entry table parsing
  defp parse_entry_table(%Gpd{entry_table_count: count} = gpd, table_binary) do
    %Gpd{ gpd | entries: GpdEntry.parse_entry_table(table_binary, count) }
  end

  # Free space table parsing
  defp parse_free_space_table(%Gpd{free_space_table_count: count} = gpd, table_binary) do
    %Gpd{ gpd | free_space: GpdFreeSpace.parse_free_space_table(table_binary, count)}
  end

  defp parse_entries(%Gpd{entries: entries, free_space: free_space} = gpd) do
    entries
    |> Enum.concat(free_space)
    |> Enum.sort(fn(x, y) -> x.offset < y.offset end)
    |> Enum.reduce(gpd, &parse_entry/2)
  end

  defp parse_entry(%GpdEntry{namespace: @ns_achievement} = entry, %Gpd{} = gpd), do: GpdAchievementEntry.parse_entry(entry, gpd)
  defp parse_entry(%GpdEntry{namespace: @ns_image} = entry, %Gpd{} = gpd), do: GpdImageEntry.parse_entry(entry, gpd)
  defp parse_entry(%GpdEntry{namespace: @ns_setting} = entry, %Gpd{} = gpd), do: GpdSettingEntry.parse_entry(entry, gpd)
  defp parse_entry(%GpdEntry{namespace: @ns_title} = entry, %Gpd{} = gpd), do: GpdTitleEntry.parse_entry(entry, gpd)
  defp parse_entry(%GpdEntry{namespace: @ns_string} = entry, %Gpd{} = gpd), do: GpdStringEntry.parse_entry(entry, gpd)

  # Base entry for anything I missed
  defp parse_entry(%GpdEntry{length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    IO.puts "TODO: Write parser for namespace #{entry.namespace}, id: #{entry.id |> Integer.to_string(16)}"

    << entry_data::binary-size(len), remaining_data::binary >> = data
    IO.inspect entry_data

    %Gpd{ gpd | remaining_data: remaining_data }
  end

  defp parse_entry(%GpdFreeSpace{length: len, offset: offset}, %Gpd{} = gpd) when bxor(offset, 0xFFFFFFFF) == len do
    %Gpd{ gpd | achievements: gpd.achievements |> Enum.reverse, settings: gpd.settings |> Enum.reverse }
  end

  defp parse_entry(%GpdFreeSpace{length: len}, %Gpd{remaining_data: data} = gpd) do
    << _::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | remaining_data: remaining_data}
  end
end

