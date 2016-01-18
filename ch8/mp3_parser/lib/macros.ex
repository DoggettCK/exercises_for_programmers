defmodule Macros do
  defmodule ID3_v2_2 do
    defmacro __using__(_options) do
      quote do
        import unquote(__MODULE__)
      end
    end

    defmacro text_frame(tag, json_name) do
      quote do
        def parse_frame(data_dict, << unquote(tag), size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
          << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

          parse_frame(data_dict |> Dict.put(unquote(json_name), frame_data |> StringUtils.decode_string), remaining_frame_data)
        end
      end
    end    
  end

  defmodule ID3_v2_3 do
    defmacro __using__(_options) do
      quote do
        import unquote(__MODULE__)
      end
    end

    defmacro text_frame(tag, json_name) do
      quote do
        def parse_frame(data_dict, << unquote(tag), size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
          size = size - 1 # strip off encoding byte

          << _encoding::binary-size(1), frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

          parse_frame(data_dict |> Dict.put(unquote(json_name), frame_data |> StringUtils.decode_string), remaining_frame_data)
        end
      end
    end
  end
end
