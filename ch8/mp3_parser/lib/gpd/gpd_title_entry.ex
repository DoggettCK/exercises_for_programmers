defmodule GpdTitleEntry do
  defstruct title_id: nil,
  achievement_count: 0,
  achievement_unlocked_count: 0,
  gamerscore_total: 0,
  gamerscore_unlocked: 0,
  unknown: nil,
  achievement_unlocked_online_count: 0,
  avatar_assets_earned: 0,
  avatar_assets_max: 0,
  male_avatar_assets_earned: 0,
  male_avatar_assets_max: 0,
  female_avatar_assets_earned: 0,
  female_avatar_assets_max: 0,
  flags: 0,
  last_played_time: nil,
  title_name: nil

  # Entry IDs
  @sync_list 0x100000000
  @sync_data 0x200000000

  def parse_title(data) do
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
    title_name::binary >> = data

    [title_name] = :unicode.encoding_to_bom({:utf16, :big})
                    |> Kernel.<>(title_name)
                    |> StringUtils.decode_string
                    |> String.split(<<0>>, trim: true)

    %GpdTitleEntry{
      title_id: title_id,
      achievement_count: achievement_count,
      achievement_unlocked_count: achievement_unlocked_count,
      gamerscore_total: gamerscore_total,
      gamerscore_unlocked: gamerscore_unlocked,
      unknown: unknown,
      achievement_unlocked_online_count: achievement_unlocked_online_count,
      avatar_assets_earned: avatar_assets_earned,
      avatar_assets_max: avatar_assets_max,
      male_avatar_assets_earned: male_avatar_assets_earned,
      male_avatar_assets_max: male_avatar_assets_max,
      female_avatar_assets_earned: female_avatar_assets_earned,
      female_avatar_assets_max: female_avatar_assets_max,
      flags: flags,
      last_played_time: last_played_time,
      title_name: title_name
    }
  end

  def parse_entry(%GpdEntry{length: len, id: id}, %Gpd{remaining_data: data} = gpd) when id in [@sync_data, @sync_list] do
    << _entry_data::binary-size(len), remaining_data::binary >> = data

    IO.puts "TODO: Title sync entry for 0x#{id |> Integer.to_string(16)}"

    %Gpd{ gpd | remaining_data: remaining_data }
  end

  def parse_entry(%GpdEntry{length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | title_entries: [GpdTitleEntry.parse_title(entry_data) | gpd.title_entries], remaining_data: remaining_data }
  end

  defimpl Inspect, for: GpdTitleEntry do
    import Inspect.Algebra

    def inspect(%GpdTitleEntry{} = entry, _opts) do
      concat ["#GpdTitleEntry<",
        entry.title_name,
        "\tAchievements: #{entry.achievement_unlocked_count}/#{entry.achievement_count}",
        "\tScore: #{entry.gamerscore_unlocked}/#{entry.gamerscore_total}",
        "\tLast Played: #{entry.last_played_time |> TimeUtils.to_human_readable}",
        ">"]
    end
  end
end
