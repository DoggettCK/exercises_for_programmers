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
  parsed_entries: []

  def test do
    {:ok, gpd_data} = File.read("/Users/cdoggett/XBox360_20160105/Content/55530879.gpd")

    Gpd.parse(gpd_data)
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
      # Length is number of entries, so multiply by entry size to get entire table
      version: version,
      entry_table_length: entry_table_length * 18,
      entry_table_count: entry_table_count,
      free_space_table_length: free_space_table_length * 8,
      free_space_table_count: free_space_table_count,
      remaining_data: remaining_data
    }
    |> parse_tables
    |> parse_entries
  end

  defp parse_tables(%Gpd{
    entry_table_length: entry_table_length,
    free_space_table_length: free_space_table_length,
    remaining_data: data
  } = gpd) do
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

  defp parse_entries(%Gpd{entries: entries, free_space: free_space, remaining_data: remaining_data} = gpd) do
    gpd.remaining_data
    |> String.slice(0, 1000) |> IO.inspect
    entries
    |> Enum.concat(free_space)
    |> Enum.sort(fn(x, y) -> x.offset < y.offset end)
    |> Enum.reduce(gpd, &parse_entry/2)
  end

  defp parse_entry(%GpdEntry{namespace: 5, id: 0x8000, length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    title = (:unicode.encoding_to_bom({:utf16, :big}) <> entry_data)
            |> StringUtils.decode_string
            |> String.split(<<0>>, trim: true)
            |> hd
    #TODO: Get rid of parsed_entries, make list of achievements, settings, etc...

    %Gpd{ gpd | title: title, parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 1, id: 0x100000000, length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    IO.puts "TODO: Achievement sync list" 

    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 1, id: 0x200000000, length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    IO.puts "TODO: Achievement sync data" 

    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 3, id: 0x200000000, length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    IO.puts "TODO: Setting sync data" 

    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{namespace: 1, length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    IO.puts "TODO: Achievement data" 
    IO.inspect entry
    IO.inspect entry_data

    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdEntry{length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    IO.puts "TODO: Write parser for namespace #{entry.namespace}, id: #{entry.id |> Integer.to_string(16)}"

    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data }
  end

  defp parse_entry(%GpdFreeSpace{length: len, offset: offset} = entry, %Gpd{} = gpd) when bxor(offset, 0xFFFFFFFF) == len do
    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries] |> Enum.reverse }
  end

  defp parse_entry(%GpdFreeSpace{length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | parsed_entries: [entry | gpd.parsed_entries], remaining_data: remaining_data}
  end
end

