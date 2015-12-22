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

  ### Null-stripping

  def clean_string(s) when is_binary(s) do
    s |> String.chunk(:printable) |> Enum.filter(&String.printable?/1) |> first_string
  end

  defp first_string([]), do: ""
  defp first_string([head | _tail]), do: head
end
