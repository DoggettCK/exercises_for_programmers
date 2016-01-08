defmodule GpdParser do
  def parse(file_name) do
    case File.read(file_name) do
      {:ok, gpd} ->
        << "XDBF",
        version::unsigned-integer-size(32),
        entry_table_length::unsigned-integer-size(32),
        entry_count::unsigned-integer-size(32),
        free_space_table_length::unsigned-integer-size(32),
        free_space_table_entry_count::unsigned-integer-size(32),
        remaining_data::binary>> = gpd

        # Length is number of entries, so multiply by entry size to get entire table
        entry_table_length = entry_table_length * 18
        free_space_table_length = free_space_table_length * 8

        << entry_table::binary-size(entry_table_length),
        free_space_table::binary-size(free_space_table_length),
        remaining_data::binary>> = remaining_data

        entries = parse_entry_table(entry_count, entry_table)
        free_space = parse_free_space_table(free_space_table_entry_count, free_space_table)

        {parsed_entries, remaining_data} = (entries ++ free_space) 
                                            |> offset_dict
                                            |> Enum.sort
                                            |> parse_entries(remaining_data) 

        title = parsed_entries
                |> Enum.filter_map(fn {key, _} -> key == :title end, fn {_, value} -> value end)
                |> hd
        achievements = parsed_entries
                |> Enum.filter_map(fn {key, _} -> key == :achievement end, fn {_, value} -> value end)

        Dict.merge title, %{
          achievements: achievements
        } 
      _ ->
        IO.puts "Couldn't open #{file_name}"
        %{}
    end
  end

  # Entry table parsing
  def parse_entry_table(entry_count, data) do
    parse_entry_table([], entry_count, data)
  end

  defp parse_entry_table(entries, 0, _data), do: entries
  defp parse_entry_table(entries, count, data) do
    << namespace::unsigned-integer-size(16),
    id::unsigned-integer-size(64),
    offset_specifier::unsigned-integer-size(32),
    entry_length::unsigned-integer-size(32),
    remaining_data::binary >> = data

    parse_entry_table([%{namespace: namespace, id: id, offset_specifier: offset_specifier, entry_length: entry_length} | entries], count - 1, remaining_data)
  end

  # Free space table parsing
  def parse_free_space_table(entry_count, data) do
    parse_free_space_table([], entry_count, data)
  end

  defp parse_free_space_table(entries, 0, _data), do: entries
  defp parse_free_space_table(entries, count, data) do
    << offset_specifier::unsigned-integer-size(32),
    entry_length::unsigned-integer-size(32),
    remaining_data::binary >> = data
    
    parse_free_space_table([%{offset_specifier: offset_specifier, entry_length: entry_length} | entries], count - 1, remaining_data)
  end

  def offset_dict(list) do
    offset_dict(list, %{})
  end

  defp offset_dict([], dict), do: dict
  defp offset_dict([head | tail], dict) do
    {offset, rest} = Dict.pop(head, :offset_specifier)

    offset_dict(tail, dict |> Dict.put(offset, rest))
  end

  # Entry parsing
  def parse_entries(entries, data) do
    parse_entries(entries, [], data)
  end

  defp parse_entries([], entries, data), do: {entries, data}
  defp parse_entries([{offset, entry} | tail], entries, data) do
    {key, entry_dict, remaining_data} = parse_entry(entry, data)

    parse_entries(tail, [{ key, entry_dict } | entries], remaining_data)
  end
  
  defp parse_entry(%{:namespace => 5, :id => 0x8000, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    # TODO: Refactor StringUtils.decode_string to use :unicode.characters_to_binary based on encoding
    title = entry_data |> :unicode.characters_to_binary({:utf16, :big}, :utf8) |> String.split(<<0>>, trim: true) |> hd

    {:title, %{title: title}, remaining_data}
  end

  defp parse_entry(%{:namespace => 1, :id => 0x100000000, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    # TODO: Parse sync list

    {:sync_list, %{sync_list: entry_data}, remaining_data}
  end

  defp parse_entry(%{:namespace => 1, :id => 0x200000000, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    # TODO: Parse sync data

    {:sync_data, %{sync_data: entry_data}, remaining_data}
  end

  defp parse_entry(%{:namespace => 5, :id => id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    decoded_string = entry_data |> :unicode.characters_to_binary({:utf16, :big}, :utf8) |> String.split(<<0>>, trim: true) |> hd

    {:string, %{string_id: id, string: decoded_string}, remaining_data}
  end

  defp parse_entry(%{:namespace => 1, :id => id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    << 0, 0, 0, 28,
    achievement_id :: unsigned-integer-size(32),
    image_id :: unsigned-integer-size(32),
    gamerscore :: signed-integer-size(32),
    flags :: unsigned-integer-size(32),
    unlock_time :: unsigned-integer-size(64),
    strings :: binary >> = entry_data

    [name, unlocked_desc, locked_desc | _] = strings
                                          |> :unicode.characters_to_binary({:utf16, :big}, :utf8)
                                          |> String.split(<<0>>)

    flags = parse_achievement_flags(<< flags::unsigned-integer-size(32) >>)

    # TODO: convert unlock_time to timex date
    {
      :achievement,
      %{
        id: achievement_id,
        image_id: image_id,
        gamerscore: gamerscore,
        unlocked_at: unlock_time,
        flags: flags,
        name: name,
        unlocked_desc: unlocked_desc,
        locked_desc: locked_desc
      },
      remaining_data
    }
  end

  defp parse_entry(%{:namespace => namespace, :id => id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    IO.puts "Parsing entry with namespace #{namespace}"

    {:unknown, %{}, remaining_data}
  end

  defp parse_entry(%{:entry_length => entry_length}, <<>>) do
    {:final_free_space, %{length: entry_length}, <<>>}
  end

  defp parse_entry(%{:entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    {:free_space, %{length: entry_length}, remaining_data}
  end

  defp parse_achievement_flags(<< _::size(11), edited::size(1), _::size(2), earned::size(1), earned_online::size(1), _::size(12), show_unachieved::size(1), achievement_type::size(3) >> = flags) do
    Dict.merge %{
      achievement_type: GpdEnums.achievement_type(achievement_type)
    }, ([
      edited: edited,
      earned: earned,
      earned_online: earned_online,
      show_unachieved: show_unachieved
    ] |> Enum.into(%{}, fn {k, v} -> {k, (if v == 1, do: true, else: false)} end))
  end
end
