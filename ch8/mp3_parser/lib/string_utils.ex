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

  def decode_string(str) when is_binary(str) do
    { encoding, bom_length } = :unicode.bom_to_encoding(str)

    << bom::binary-size(bom_length), str::binary >> = str

    case encoding do
      {:utf16, :big} -> :unicode.characters_to_binary(str, encoding, :utf8)
      {:utf16, :little} -> :unicode.characters_to_binary(str, encoding, :utf8)
      :latin1 -> :unicode.characters_to_binary(str, encoding, :utf8)
      {:utf32, endianness} -> :unicode.characters_to_binary(<<0, 0>> <> str, {:utf16, endianness}, :utf8)
      _ -> str
    end
  end
end
