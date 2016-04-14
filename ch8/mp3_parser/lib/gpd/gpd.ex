defmodule Gpd do
  use Bitwise

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
  setting_sync_list: []


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

  defp parse_entry(%GpdEntry{namespace: 5, id: 0x8000, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    title = (:unicode.encoding_to_bom({:utf16, :big}) <> entry_data)
            |> StringUtils.decode_string
            |> String.split(<<0>>, trim: true)
            |> hd

    %Gpd{ gpd | title: title, remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 1, id: 0x100000000, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | achievement_sync_list: GpdSyncEntry.parse_sync_list(entry_data), remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 1, id: 0x200000000, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | achievement_sync_data: GpdSyncData.parse(entry_data), remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 3, id: 0x100000000, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | setting_sync_list: GpdSyncEntry.parse_sync_list(entry_data), remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 3, id: 0x200000000, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | setting_sync_data: GpdSyncData.parse(entry_data), remaining_data: remaining_data }
  end

  # TODO: make part of the parser convert setting id to meaningful atom
  for setting <- [0x10040003, 0x10040002, 0x10040018, 0x10040015, 0x10040038, 0x10040039] do
    defp parse_entry(%GpdEntry{namespace: 3, id: unquote(setting), length: len}, %Gpd{remaining_data: data} = gpd) do
      << entry_data::binary-size(len), remaining_data::binary >> = data

      %Gpd{ gpd | settings: [GpdSettingEntry.parse(entry_data) | gpd.settings], remaining_data: remaining_data }
    end
  end

  defp parse_entry(%GpdEntry{namespace: 3, id: id, length: len}, %Gpd{remaining_data: data} = gpd) when id in [0x63E83FFD, 0x63E83FFE, 0x63E83FFF] do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | settings: [GpdBinarySettingEntry.parse(id, entry_data) | gpd.settings], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 1, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | achievements: [GpdAchievementEntry.parse(entry_data) | gpd.achievements], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 2, length: len, id: id}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | images: [GpdImageEntry.parse(id, entry_data) | gpd.images], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 4, length: len, id: id}, %Gpd{remaining_data: data} = gpd)
  when id in [0x200000000] do
    << entry_data::binary-size(len), remaining_data::binary >> = data
    IO.puts "TODO: Title entry for 0x#{id |> Integer.to_string(16)}"
    %Gpd{ gpd | remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 4, length: len, id: id}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    IO.puts "Parsing title entry for #{id |> Integer.to_string(16)}.gpd"

    << title_id::unsigned-integer-size(32),
    achievement_count::signed-integer-size(32),
    achievement_unlocked_count::signed-integer-size(32),
    gamerscore_total::signed-integer-size(32),
    gamerscore_unlocked::signed-integer-size(32),
    unknown::unsigned-integer-size(8),
    achievement_unlocked_online_count::unsigned-integer-size(8),
    avatar_assets_earned::unsigned-integer-size(8),
    avatar_assets_max::unsigned-integer-size(8),
    male_avatar_assets_earned::unsigned-integer-size(8),
    male_avatar_assets_max::unsigned-integer-size(8),
    female_avatar_assets_earned::unsigned-integer-size(8),
    female_avatar_assets_max::unsigned-integer-size(8),
    flags::unsigned-integer-size(32),
    last_played_time::signed-integer-size(64),
    title_name::binary >> = entry_data

    [title_name] = StringUtils.decode_string(:unicode.encoding_to_bom({:utf16, :big}) <> title_name) |> String.split(<<0>>, trim: true)

    IO.puts "Title: #{title_name}"
    IO.puts "Title ID: #{title_id |> Integer.to_string(16)}"
    IO.puts "Achievement count: #{achievement_count}"
    IO.puts "Unlocked achievement count: #{achievement_unlocked_count}"
    IO.puts "Total Gamerscore: #{gamerscore_total}"
    IO.puts "Unlocked Gamerscore: #{gamerscore_unlocked}"
    IO.puts "Unknown byte: #{unknown}"
    IO.puts "Unlocked online achievement count: #{achievement_unlocked_online_count}"
    IO.puts "Avatar assets earned: #{avatar_assets_earned}"
    IO.puts "Avatar assets max: #{avatar_assets_max}"
    IO.puts "Male Avatar assets earned: #{male_avatar_assets_earned}"
    IO.puts "Male Avatar assets max: #{male_avatar_assets_max}"
    IO.puts "Female Avatar assets earned: #{female_avatar_assets_earned}"
    IO.puts "Female Avatar assets max: #{female_avatar_assets_max}"
    IO.puts "Flags: #{flags |> Integer.to_string(2) |> String.rjust(32, ?0)}"
    IO.puts "Last played time: #{last_played_time |> TimeUtils.filetime_to_datetime |> TimeUtils.datetime_to_tuples |> TimeUtils.tuples_to_iso8601}"

    %Gpd{ gpd | remaining_data: remaining_data }
  end

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

