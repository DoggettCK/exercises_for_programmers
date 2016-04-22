defmodule GpdAchievementEntry do
  defstruct id: nil, image: nil, gamerscore: 0, flags: 0, unlock_time: nil, name: nil, unlocked_desc: nil, locked_desc: nil 

  # Entry IDs
  @sync_list 0x100000000
  @sync_data 0x200000000

  def parse_achievement(data) do
    << 0x1C::unsigned-integer-size(32),
    id::unsigned-integer-size(32),
    image_id::unsigned-integer-size(32),
    gamerscore::signed-integer-size(32),
    flags::unsigned-integer-size(32),
    unlock_time::unsigned-integer-size(64),
    strings::binary >> = data

    [name, unlocked, locked] = GpdStringUtils.split_null_terminated(strings, 3)
    
    %GpdAchievementEntry{
      id: id,
      image: image_id,
      gamerscore: gamerscore,
      flags: GpdAchievementFlags.parse(flags),
      unlock_time: unlock_time,
      name: name,
      unlocked_desc: unlocked,
      locked_desc: locked
    }
  end

  # Sync list/data are special
  def parse_entry(%GpdEntry{id: @sync_list, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | achievement_sync_list: GpdSyncEntry.parse_sync_list(entry_data), remaining_data: remaining_data }
  end

  def parse_entry(%GpdEntry{id: @sync_data, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | achievement_sync_data: GpdSyncData.parse(entry_data), remaining_data: remaining_data }
  end

  # All the rest are actual achievement entries
  def parse_entry(%GpdEntry{length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    %Gpd{ gpd | achievements: [parse_achievement(entry_data) | gpd.achievements], remaining_data: remaining_data }
  end
end
