defmodule GeneratePassword do
  require Macros

  alphabets = [
    alpha: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    special:  "~`!@#$%^&*?",
    digits: "0123456789",
  ] 

  for {name, chars} <- alphabets do
    Macros.define_alphabet name, chars
  end

  # or alphabets |> Enum.map fn {name, chars} -> Macros.define_alphabet name, chars end
  # or Macros.define_alphabet :alpha2, "abcd1234"

  def generate_password(min_length, n_special, n_digits) do
    []
    |> choose_alpha(min_length - n_special - n_digits)
    |> choose_special(n_special)
    |> choose_digits(n_digits)
    |> Enum.shuffle
    |> Enum.join
  end
end
