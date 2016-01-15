defmodule GpdParser do
  use Bitwise

  def parse(file_name) do
    case File.read(file_name) do
      {:ok, gpd} ->

        # http://www.free60.org/wiki/GPD
        << "XDBF",
        _version::unsigned-integer-size(32),
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

        {parsed_entries, _remaining_data} = (entries ++ free_space) 
                                            |> offset_dict
                                            |> Enum.sort
                                            |> parse_entries(remaining_data) 

        title = parsed_entries
                |> Enum.filter_map(fn {key, _} -> key == :title end, fn {_, value} -> value end)
                |> hd

        achievements = parsed_entries
                        |> Enum.filter_map(fn {key, _} -> key == :achievement end, fn {_, value} -> value end)
                        |> Enum.sort(fn d1, d2 -> d2.unlocked_at <= d1.unlocked_at end)

        settings = parsed_entries
                    |> Enum.filter_map(fn {key, _} -> key == :setting end, fn {_, value} -> value end)
                    |> Enum.into %{}

        _sync_list = parsed_entries
                    |> Enum.filter_map(fn {key, _} -> key == :sync_list end, fn {_, value} -> value end)

        _sync_data = parsed_entries
                    |> Enum.filter_map(fn {key, _} -> key == :sync_data end, fn {_, value} -> value end)

        Dict.merge title, %{
          achievements: achievements,
          settings: settings,
          #sync_list: sync_list,
          #sync_data: sync_data
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
  defp parse_entries([{_offset, entry} | tail], entries, data) do
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

    {:sync_data, parse_sync_data(entry_data) , remaining_data}
  end

  defp parse_entry(%{:namespace => 2, :id => id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    {:image, %{id: id, data:  "data:image/png;base64,#{:base64.encode(entry_data)}"}, remaining_data}
  end


  defp parse_entry(%{:namespace => 3, :id => id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    << setting_id::signed-integer-size(32), 
    dos_time::unsigned-integer-size(16),
    unknown::unsigned-integer-size(16),
    data_type::unsigned-integer-size(8),
    _::binary-size(7),
    data::binary >> = entry_data

    setting_data = %{
      id: id,
      setting_id: setting_id,
      dos_time: dos_time,
      unknown: unknown |> Integer.to_string(2),
      data_type: data_type,
      data: data
    } |> parse_setting_data

    {:setting, setting_data, remaining_data}
  end

  defp parse_entry(%{:namespace => 5, :id => id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    decoded_string = entry_data |> :unicode.characters_to_binary({:utf16, :big}, :utf8) |> String.split(<<0>>, trim: true) |> hd

    {:string, %{string_id: id, string: decoded_string}, remaining_data}
  end

  defp parse_entry(%{:namespace => 1, :id => achievement_id, :entry_length => entry_length}, data) do
    << entry_data::binary-size(entry_length), remaining_data::binary >> = data

    << 0, 0, 0, 28,
    ^achievement_id :: unsigned-integer-size(32),
    image_id :: unsigned-integer-size(32),
    gamerscore :: signed-integer-size(32),
    flags :: unsigned-integer-size(32),
    unlock_time :: unsigned-integer-size(64),
    strings :: binary >> = entry_data

    [name, unlocked_desc, locked_desc | _] = strings
                                          |> :unicode.characters_to_binary({:utf16, :big}, :utf8)
                                          |> String.split(<<0>>)

    {
      :achievement,
      %{
        id: achievement_id,
        image_id: image_id,
        gamerscore: gamerscore,
        unlocked_at: unlock_time,
        unlocked_time: TimeUtils.filetime_to_datetime(unlock_time),
        flags: parse_achievement_flags(flags),
        name: name,
        unlocked_desc: unlocked_desc,
        locked_desc: locked_desc
      },
      remaining_data
    }
  end

  defp parse_entry(%{:namespace => namespace, :id => id, :entry_length => entry_length}, data) do
    << _entry_data::binary-size(entry_length), remaining_data::binary >> = data

    IO.puts "Parsing entry with namespace #{namespace}, id #{id}, length #{entry_length}"

    {:unknown, %{}, remaining_data}
  end

  defp parse_entry(%{:entry_length => entry_length}, <<>>) do
    {:final_free_space, %{length: entry_length}, <<>>}
  end

  defp parse_entry(%{:entry_length => entry_length}, data) do
    << _entry_data::binary-size(entry_length), remaining_data::binary >> = data

    {:free_space, %{length: entry_length}, remaining_data}
  end

  defp parse_achievement_flags(flags) when is_integer(flags) do
    #IO.puts (flags |> Integer.to_string(2))

    GpdEnums.flags
    |> Enum.map(&({&1, flags |> GpdEnums.flag_set?(&1)}))
    |> Enum.into(%{
      achievement_type: GpdEnums.achievement_type(flags &&& 0x7),
      system_xbox: !(GpdEnums.flag_set?(flags, :system_ios_android_win8) || GpdEnums.flag_set?(flags, :system_gfwl_wp8))
    })
  end

  defp parse_setting_data(%{:setting_id => 0x10040038, :id => 0x10040038, :data_type => 1, :data => data}) do
    << gamerscore_earned::unsigned-integer-size(32), _rest::binary >> = data

    {:gamerscore_earned, gamerscore_earned}
  end

  defp parse_setting_data(%{:setting_id => 0x10040039, :id => 0x10040039, :data_type => 1, :data => data}) do
    << achievements_earned::unsigned-integer-size(32), _rest::binary >> = data

    {:achievements_earned, achievements_earned}
  end

  defp parse_setting_data(%{:id => 0x100000000, :setting_id => 0x100000000, :data_type => 0, :data => data}) do
    {:sync_list, parse_sync_list(data)}
  end

  defp parse_setting_data(%{:id => 0x200000000, :setting_id => 0x200000000, :data_type => 0, :data => data}) do
    {:sync_data, parse_sync_data(data)}
  end

  defp parse_setting_data(%{:id => 0x63E83FFF, :setting_id => 0x63E83FFF, :data_type => _data_type, :data => _data}) do
    {:title_specific_1, nil}
  end

  defp parse_setting_data(%{:id => _id, :setting_id => _setting_id, :data_type => _data_type, :data => _data}) do
    {:unknown_setting, nil}
  end

  defp parse_sync_list(sync_list_binary) do
    parse_sync_list(sync_list_binary, [])
  end

  defp parse_sync_list(<<>>, sync_list_entries), do: sync_list_entries
  defp parse_sync_list(<< entry_id::unsigned-integer-size(64), sync_id::unsigned-integer-size(64), rest::binary >>, sync_list_entries) do
    parse_sync_list(rest, [%{:entry_id => entry_id, :sync_id => sync_id} | sync_list_entries])
  end

  defp parse_sync_data(<< next_synced_id::unsigned-integer-size(64), last_synced_id::unsigned-integer-size(64), last_synced_time::unsigned-integer-size(64) >>) do
    %{
      :last_synced_time => last_synced_time,
      :last_synced_id => last_synced_id,
      :next_synced_id => next_synced_id
    }
  end

  defp parse_sync_data(<< last_synced_time::unsigned-integer-size(64) >>) do
    %{
      :last_synced_time => last_synced_time
    }
  end
end
