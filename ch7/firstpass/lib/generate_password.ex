defmodule GeneratePassword do
  require Macros

  Macros.define_alphabet :alpha, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  Macros.define_alphabet :special,  "~`!@#$%^&*?"
  Macros.define_alphabet :digits, "0123456789"

  def generate_password(min_length, n_special, n_digits) do
    []
    |> choose_alpha(min_length - n_special - n_digits)
    |> choose_special(n_special)
    |> choose_digits(n_digits)
    |> Enum.shuffle
    |> Enum.join
  end

  defp pick_random(alphabet) do
    len = String.length(alphabet) - 1

    alphabet |> String.at :random.uniform(len)
  end

  # TODO: Figure out why this doesn't work
  alphabets = [
    alpha: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    special:  "~`!@#$%^&*?",
    digits: "0123456789",
  ] 

  for {_name, _chars} <- alphabets do
    #Macros.define_alphabet name, chars
  end
end
