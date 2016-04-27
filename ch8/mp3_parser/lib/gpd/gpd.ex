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
  title_sync_data: nil,
  achievement_sync_list: [],
  setting_sync_list: [],
  title_sync_list: [],
  title_entries: []

  def test do
    [
      "534307F6", "534307FF", "5343080B", "5343080C", "534507F1", "5345085E", "535107FA", "53510803",
      "53510811", "5351081E", "5451086D", "545108AE", "545407D8", "5454081A", "5454082B", "58410877",
      "58410889", "584108B7", "584108CE", "584108EC", "584108F6", "584108FF", "5841090D", "58410927",
      "5841095A", "58410960", "5841097D", "5841098F", "58410995", "58410999", "584112A5", "584112B0",
      "584113BF", "5841140A", "58411413", "5841141A", "5841143A", "58411441", "58411452", "5841147C",
      "58411488", "58411498", "5848085B", "58480880", "584A07D1", "59331389", "314C1391", "314C1398",
      "325A07D1", "394707D1", "415407D7", "415607E7", "415607F7", "415608EC", "423607D1", "425307D1",
      "425307D6", "425307E0", "425307E3", "425307F5", "425607D9", "434307D2", "4D530AB5", "4D5313A1",
      "4D5313A8", "4D5313BC", "4D5313DA", "4D5313F1", "4D5313F2", "4D531467", "4D531468", "4D53148E",
      "4D53148F", "4E441389", "4E44138B", "4E44139E", "4E5707D1", "523207DB", "57520802", "57520817",
      "5752081D", "57520824", "57520828", "57520829", "57520835", "57520FA0", "584107D1", "584107F1",
      "584107F3", "5841080D", "5841083E", "58410840", "5841085C", "5841086A", "58410A7E", "58410A8C",
      "58410A8D", "58410A95", "58410AF9", "58410AFA", "58410B00", "58410B19", "58410B62", "58410B66",
      "58410B8D", "584111DE", "58411216", "58411228", "5841124A", "434307E0", "4343082F", "454107D2",
      "4541080F", "45410829", "45410850", "45410857", "45410869", "454108C0", "454108C5", "454108CE",
      "4541090B", "45410923", "45410935", "4541095D"
    ]
    |> Enum.map(&{"/Users/cdoggett/XBox360_20160105/Content/#{&1}.gpd", &1})
    |> Enum.map(&read_and_parse/1)
  end

  defp read_and_parse({file_path, gpd_id}) do
    File.read!(file_path)
    |> Gpd.parse(gpd_id)
  end


  def parse(file_data, gpd_id) do
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

  for {namespace, parser} <- %{
    @ns_achievement => GpdAchievementEntry,
    @ns_image => GpdImageEntry,
    @ns_setting => GpdSettingEntry,
    @ns_title => GpdTitleEntry,
    @ns_string =>  GpdStringEntry,
  } do
    defp parse_entry(%GpdEntry{namespace: unquote(namespace)} = entry, %Gpd{} = gpd), do: unquote(parser).parse_entry(entry, gpd)
  end

  # Base entry for anything I missed
  defp parse_entry(%GpdEntry{length: len} = entry, %Gpd{remaining_data: data} = gpd) do
    IO.puts "TODO: Write parser for namespace #{entry.namespace}, id: #{entry.id |> Integer.to_string(16)}"

    << entry_data::binary-size(len), remaining_data::binary >> = data
    IO.inspect entry_data

    %Gpd{ gpd | remaining_data: remaining_data }
  end

  defp parse_entry(%GpdFreeSpace{length: len, offset: offset}, %Gpd{} = gpd) when bxor(offset, 0xFFFFFFFF) == len do
    %Gpd{ gpd |
      achievements: gpd.achievements |> Enum.reverse,
      settings: gpd.settings |> Enum.reverse
    }
  end

  defp parse_entry(%GpdFreeSpace{length: len}, %Gpd{remaining_data: data} = gpd) do
    << _::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | remaining_data: remaining_data}
  end
end

