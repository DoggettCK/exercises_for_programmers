defmodule SynchSafe do
  use Bitwise

  def synchsafe(i) when is_integer(i) do
    synchsafe(i, 0x7F)
  end

  def unsynchsafe(i) when is_integer(i) do
    unsynchsafe(i, 0x7F000000, 0)
  end

  # In most languages, this would be 0, as the signed int would overflow
  # In Elixir, due to arbitrarily large ints, it'll go on probably until
  # the system runs out of memory, so kill it at the next mask bigger than 2^31-1
  defp synchsafe(i, 0x7FFFFFFFFF), do: i

  defp synchsafe(i, mask) do
    synchsafe(((i &&& bnot(mask)) <<< 1) ||| (i &&& mask), ((mask + 1) <<< 8) - 1)
  end

  defp unsynchsafe(_i, 0, out), do: out

  defp unsynchsafe(i, mask, out) do
    unsynchsafe(i, mask >>> 8, (out >>> 1) ||| (i &&& mask))
  end
end
