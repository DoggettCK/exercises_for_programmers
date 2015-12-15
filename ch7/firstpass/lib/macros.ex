defmodule Macros do
  defmacro define_alphabet(name, chars) do
    quote do
      def unquote(:"choose_#{name}")(chosen, 0) do
        chosen
      end

      def unquote(:"choose_#{name}")(chosen, n) do
        alphabet = unquote(chars) 

        unquote(:"choose_#{name}")([pick_random(alphabet) | chosen], n - 1)
      end
    end
  end
end

