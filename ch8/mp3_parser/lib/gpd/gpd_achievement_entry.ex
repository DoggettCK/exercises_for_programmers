defmodule GpdAchievementEntry do
  defstruct id: nil, image: nil, gamerscore: 0, flags: 0, unlock_time: nil, name: nil, unlocked_desc: nil, locked_desc: nil 

  def parse(data) do
    << 0x1C::unsigned-integer-size(32),
    id::unsigned-integer-size(32),
    image_id::unsigned-integer-size(32),
    gamerscore::signed-integer-size(32),
    flags::unsigned-integer-size(32),
    unlock_time::unsigned-integer-size(64),
    strings::binary >> = data

    [name, unlocked, locked] = (:unicode.encoding_to_bom({:utf16, :big}) <> strings)
                                |> StringUtils.decode_string
                                |> String.split(<<0>>, trim: true)
                                |> Enum.concat(["", "", ""]) # Way to meet the spec, GH3
                                |> Enum.take(3)
    
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
end
