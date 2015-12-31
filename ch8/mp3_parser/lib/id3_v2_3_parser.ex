defmodule ID3_v2_3_Parser do
  def parse_frame(data_dict, << "TALB", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("album", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TCON", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("content_type", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TYER", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("year", frame_data |> StringUtils.decode_string |> String.to_integer), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIT2", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("title", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE1", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("lead_performer", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE2", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("band", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TBPM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("beats_per_minute", frame_data |> StringUtils.decode_string |> String.to_integer), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSSE", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("encoding_settings", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TRCK", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("track_number", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "COMM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    comments = [parse_comment_frame(frame_data) | data_dict |> Dict.get("comments", [])]

    parse_frame(data_dict |> Dict.put("comments", comments), remaining_frame_data)
  end

  def parse_frame(data_dict, << "APIC", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    pictures = [parse_picture_frame(frame_data) | data_dict |> Dict.get("pictures", [])]

    parse_frame(data_dict |> Dict.put("pictures", pictures), remaining_frame_data)
  end

  def parse_frame(data_dict, << 0, 0, 0, 0, _::binary-size(6), remaining_frame_data::binary >>) do
    parse_frame(data_dict, remaining_frame_data)
  end

  def parse_frame(data_dict, <<>>) do
    data_dict
  end

  def parse_frame(data_dict, frame_data) do
    << frame_type::binary-size(4), _remaining_frame_data::binary >> = frame_data

    IO.puts "Unknown frame type #{inspect frame_type}"

    data_dict
  end

  ### APIC frame parsing
  defp parse_picture_frame(frame_data) do
    # TODO: Break this up like comment parser by encoding
    << frame_encoding::unsigned-integer-size(8), remaining_data::binary >> = frame_data

    {mime_type, remaining_data} = StringUtils.read_null_terminated_string(remaining_data)

    << picture_type::unsigned-integer-size(8), remaining_data::binary >> = remaining_data

    {description, picture_data} = StringUtils.read_null_terminated_string(remaining_data)

    %{}
    |> Dict.put("encoding", Enums.encoding(frame_encoding))
    |> Dict.put("mime_type", mime_type)
    |> Dict.put("picture_type", Enums.picture_type(picture_type))
    |> Dict.put("picture_description", description)
    |> Dict.put("image", "data:#{mime_type};base64,#{:base64.encode(picture_data)}")
  end

  ### Comment frame parsing
  defp parse_comment_frame(<< 0, language::binary-size(3), comment_data::binary >>) do
    [short_description, actual_text | _] = comment_data |> String.split(<<0>>)

    %{}
    |> Dict.put("encoding", "ISO-8859-1")
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end

  defp parse_comment_frame(<< 1, language::binary-size(3), comment_data::binary >>) do
    # Reattach the encoding so the decoder can parse them correctly
    [short_description, actual_text | _] = comment_data 
                                            |> String.split(<<0, 0>>)
                                            |> Enum.map(&(<<1>> <> &1))
                                            |> Enum.map(&StringUtils.decode_string/1)

    %{}
    |> Dict.put("encoding", "UTF-8")
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end

end
