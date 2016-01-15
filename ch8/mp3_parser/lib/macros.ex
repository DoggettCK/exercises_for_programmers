defmodule Macros do
  defmodule ID3_v2_2 do
    defmacro __using__(_options) do
      quote do
        import unquote(__MODULE__)
      end
    end

    defp simple_frame(tag, json_name, transform) do
      quote do
        def parse_frame(data_dict, << unquote(tag), size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
          << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

          value = unquote(transform)

          parse_frame(data_dict |> Dict.put(unquote(json_name), value), remaining_frame_data)
        end
      end
    end    

    defmacro text_frame(tag, json_name) do
      simple_frame(tag, json_name, quote(do: frame_data |> StringUtils.decode_string))
    end

    defmacro integer_frame(tag, json_name) do
      simple_frame(tag, json_name, quote(do: frame_data |> StringUtils.decode_string |> String.to_integer))
    end    
  end

  defmodule ID3_v2_3 do
    defmacro __using__(_options) do
      quote do
        import unquote(__MODULE__)
      end
    end

    defp simple_frame(tag, json_name, transform) do
      quote do
        def parse_frame(data_dict, << unquote(tag), size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
          << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

          value = unquote(transform)

          parse_frame(data_dict |> Dict.put(unquote(json_name), value), remaining_frame_data)
        end
      end
    end

    defmacro text_frame(tag, json_name) do
      simple_frame(tag, json_name, quote(do: frame_data |> StringUtils.decode_string))
    end

    defmacro integer_frame(tag, json_name) do
      simple_frame(tag, json_name, quote(do: frame_data |> StringUtils.decode_string |> String.to_integer))
    end
  end
end
