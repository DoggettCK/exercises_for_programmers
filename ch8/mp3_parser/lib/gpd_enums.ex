defmodule GpdEnums do
  use Bitwise

  for {val, desc} <- %{
    0x100000000 => "Sync List", 
    0x10040002 => "Gamer Yaxis Inversion", 
    0x10040003 => "Option Controller Vibration", 
    0x10040004 => "Gamercard Zone", 
    0x10040005 => "Gamercard Region", 
    0x10040006 => "Gamercard Cred", 
    0x10040012 => "Option Voice Muted", 
    0x10040013 => "Option Voice Thru Speakers", 
    0x10040014 => "Option Voice Volume", 
    0x10040018 => "Gamercard Titles Played", 
    0x10040019 => "Gamercard Achievements Earned", 
    0x10040021 => "Gamer Difficulty", 
    0x10040024 => "Gamer Control Sensitivity", 
    0x10040029 => "Gamer Preferred Color First", 
    0x10040030 => "Gamer Preferred Color Second", 
    0x10040034 => "Gamer Action Auto Aim", 
    0x10040035 => "Gamer Action Auto Center", 
    0x10040036 => "Gamer Action Movement Control", 
    0x10040038 => "Gamer Race Transmission", 
    0x10040039 => "Gamer Race Camera Location", 
    0x10040040 => "Gamer Race Brake Control", 
    0x10040041 => "Gamer Race Accelerator Control", 
    0x10040056 => "Gamercard Title Cred Earned", 
    0x10040057 => "Gamercard Title Achievements Earned", 
    0x10040063 => "Option Voice Thru Speakers Raw", 
    0x200000000 => "Sync Data", 
    0x402C0011 => "Gamercard Motto", 
    0x40520041 => "Gamer Location", 
    0x4064000F => "Gamercard Picture Key", 
    0x41040040 => "Gamer Name", 
    0x50040011 => "Gamercard Rep", 
    0x63E80068 => "Avatar Metadata", 
    0x63E83FFD => "Title Specific3", 
    0x63E83FFE => "Title Specific2", 
    0x63E83FFF => "Title Specific1", 
    0x63e80044 => "Avatar Information", 
    0x8000 => "Title Information", 
    0x8007 => "Avatar Image", 
  } do
    def entry_type(unquote(val)), do: unquote(desc)
  end

  def entry_type(_), do: "Unknown entry type"

  for {val, desc} <- %{
    1 => "Completion",
    2 => "Leveling",
    3 => "Unlock",
    4 => "Event",
    5 => "Tournament",
    6 => "Checkpoint",
    7 => "Other",
  } do
    def achievement_type(unquote(val)), do: unquote(desc)
  end

  def achievement_type(_), do: "Unknown achievement type"

  @flags %{
    0x8 => :secret,
    0x10000 => :earned_online,
    0x20000 => :earned,
    0x100000 => :edited,
    0x200000 => :system_gfwl_wp8,
    0x400000 => :system_ios_android_win8
  }

  @doc """
  Returns a list of all achievement flags
  """
  def flags, do: @flags |> Dict.values

  for {flag, flag_name } <- @flags do
    @doc """
    Determines if a flag is set on an integer, specified by an atom from `GpdEnums.flags`

    Returns: `true` or `false`
    """
    def flag_set?(flags, unquote(flag_name)) when is_integer(flags), do: (flags &&& unquote(flag)) == unquote(flag)

    @doc """
    Set or unset a flag on an integer, specified by an atom from `GpdEnums.flags`
    """
    def set_flag(flags, unquote(flag_name), 0), do: flags &&& bnot(unquote(flag))
    def set_flag(flags, unquote(flag_name), 1), do: flags ||| unquote(flag)
  end
end
