defmodule Anagram do
  def main(_args) do
    IO.puts "Enter two strings, and I'll tell you if they're anagrams:"

    one = (IO.gets "Enter the first string: ") |> String.strip
    two = (IO.gets "Enter the second string: ") |> String.strip

    IO.puts display(one, two, anagram?(one, two))
  end

  def anagram?(one, two) do
    clean(one) == clean(two)
  end

  defp display(one, two, true) do
    "\"#{one}\" and \"#{two}\" are anagrams."
  end

  defp display(one, two, _) do
    "\"#{one}\" and \"#{two}\" are not anagrams."
  end

  defp clean(s) when is_binary(s) do
    s
    |> String.downcase
    |> String.replace(~r/\W/, "")
    |> to_char_list
    |> Enum.sort
    |> to_string
  end
end
