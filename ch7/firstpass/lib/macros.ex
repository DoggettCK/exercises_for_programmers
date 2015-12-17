defmodule Macros do
  defmacro define_alphabet(name, chars) do
    quote bind_quoted: [name: name, chars: chars] do
      def unquote(:"choose_#{name}")(chosen, 0) do
        chosen
      end

      def unquote(:"choose_#{name}")(chosen, n) do
        unquote(:"choose_#{name}")([(unquote(chars) |> to_char_list |> Enum.shuffle |> Enum.take(1) |> to_string) | chosen], n - 1)
      end
    end
  end
end

