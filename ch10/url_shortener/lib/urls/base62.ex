defmodule Base62 do
  @moduledoc """
  Base62 encode/decode functions
  """
  @base 62
  @alphabet [?a..?z, ?A..?Z, ?0..?9]
  |> Enum.flat_map(fn x -> x end)
  |> to_string
  |> String.split("", trim: true)
  |> Enum.take(@base)

  @validator Regex.compile!("^[#{ @alphabet |> Enum.join }]+$")

  def alphabet, do: @alphabet |> Enum.join

  for {char, ix} <- (@alphabet |> Enum.with_index) do
    defp index_of(unquote(char)), do: unquote(ix)
    defp char_at(unquote(ix)), do: unquote(char)
  end

  @doc """
  Encodes an integer to a Base62 string

  ## Examples

  \tiex> Base62.encode(123) # "b9"
  """
  def encode(int) when is_integer(int) do
    encode(div(int, @base), rem(int, @base), "")
  end

  defp encode(0, mod, str), do: char_at(mod) <> str
  defp encode(int, mod, str) when is_integer(int) do
    encode(div(int, @base), rem(int, @base), char_at(mod) <> str)
  end

  @doc """
  Decodes a Base62 string to an integer

  ## Examples

  \tiex> Base62.decode("foo") # 20102
  """
  def decode(str) when is_binary(str) do
    case Regex.match?(@validator, str) do
      false ->
        raise "Not a valid Base62 string"
      true ->
        str
        |> String.reverse
        |> String.split("", trim: true)
        |> Enum.with_index
        |> Enum.reduce(0, fn({char, index}, acc) -> acc + index_of(char) * (:math.pow(@base, index) |> round) end)
    end
  end
end
