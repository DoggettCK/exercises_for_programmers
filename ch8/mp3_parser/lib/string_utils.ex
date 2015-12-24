defmodule StringUtils do
  def read_null_terminated_string(bin) when is_binary(bin) do
    # Given a binary, takes everything until the first null byte, returns {string, rest} 
    null_terminated_string(bin, <<>>)
  end

  defp null_terminated_string(<<0>> <> rest, s) do
    {s, rest} 
  end

  defp null_terminated_string(<<c>> <> rest, s) do
    null_terminated_string(rest, s <> <<c>>) 
  end

  def decode_string(<< 0, str::binary >>) do
    str |> String.split(<<0>>) |> hd # Remove trailling null if necessary
  end

  def decode_string(<< 1, 0xFF, 0xFE, str::binary >>) do
    read_utf8_string(str)
  end

  def decode_string(<< 1, 0xFE, 0xFF, str::binary >>) do
    read_utf8_string(str)
  end


  def read_utf8_string(str) do
    str |> String.graphemes |> Enum.reject(&(&1 == <<0>>)) |> to_string
  end
end
