defmodule GpdAchievementFlags do
  use Bitwise

  defstruct earned_online: false,
  earned: false,
  edited: false,
  show_as_secret: false,
  system_gfwl_wp8: false,
  system_ios_android_win8: false,
  achievement_type: nil

  @writable_flags %{
    earned_online: 0x10000,
    earned: 0x20000,
    edited: 0x100000,
  }

  @flags Dict.merge @writable_flags, %{
    show_as_secret: 0x8,
    system_gfwl_wp8: 0x200000,
    system_ios_android_win8: 0x400000,
  }

  @achievement_types %{
    completion: 1,
    leveling: 2,
    unlock: 3,
    event: 4,
    tournament: 5,
    checkpoint: 6,
    other: 7,
  }

  def parse(achievement_flags) do
    flags_set = @flags
                |> Enum.into(%{}, fn {k, v} -> {k, flag_set?(achievement_flags, k)} end)
                |> Map.put(:achievement_type, achievement_type(achievement_flags &&& 0x7))

    struct(GpdAchievementFlags, flags_set)
  end

  # TODO: Set writable flags

  @doc """
  Returns a list of all achievement flags
  """
  def flags, do: Map.keys(@flags)

  @doc """
  Returns a list of all writable achievement flags
  """
  def writable_flags, do: Map.keys(@writable_flags)

  for {flag_name, flag} <- @flags do
    @doc """
    Determines if a flag is set on an integer, specified by an atom from `flags`

    Returns: `true` or `false`
    """
    defp flag_set?(flags, unquote(flag_name)) when is_integer(flags), do: (flags &&& unquote(flag)) == unquote(flag)
  end

  for {flag_name, flag} <- @writable_flags do
    @doc """
    Set or unset a flag on an integer, specified by an atom from `GpdEnums.writable_flags`

    ## Examples:

    iex> GpdEnums.set_flag(0b01001, :earned_online, 1) |> Integer.to_string(2)
    "10000000000001001"
    """
    defp set_flag(flags, unquote(flag_name), 0), do: flags &&& bnot(unquote(flag))
    defp set_flag(flags, unquote(flag_name), 1), do: flags ||| unquote(flag)
    defp set_flag(flags, unquote(flag_name), false), do: flags |> set_flag(unquote(flag_name), 0) 
    defp set_flag(flags, unquote(flag_name), true), do: flags |> set_flag(unquote(flag_name), 1) 
  end

  for {desc, val} <- @achievement_types do
    def achievement_type(unquote(val)), do: unquote(desc)
  end

  def achievement_type(_), do: :unknown
end
