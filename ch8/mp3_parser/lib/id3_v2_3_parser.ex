defmodule ID3_v2_3_Parser do
  use Macros.ID3_v2_3

  text_frame "TALB", "album"
  text_frame "TBPM", "beats_per_minute"
  text_frame "TCOM", "composer"
  text_frame "TCON", "content_type"
  text_frame "TCOP", "copyright"
  text_frame "TDAT", "date"
  text_frame "TDES", "podcast_description"
  text_frame "TDLY", "delay_in_msecs"
  text_frame "TDRL", "release_time"
  text_frame "TENC", "encoded_by"
  text_frame "TEXT", "lyricist"
  text_frame "TFLT", "file_type"
  text_frame "TGID", "podcast_id"
  text_frame "TIME", "time"
  text_frame "TIT1", "content_group_description"
  text_frame "TIT2", "title"
  text_frame "TIT3", "subtitle"
  text_frame "TKEY", "initial_key"
  text_frame "TLAN", "language"
  text_frame "TLEN", "length_in_msecs"
  text_frame "TMED", "media_type"
  text_frame "TPE1", "lead_performer"
  text_frame "TPE2", "band"
  text_frame "TRCK", "track_number"
  text_frame "TSSE", "encoding_settings"
  text_frame "TYER", "year"
  text_frame "WFED", "podcast_url"

  def parse_frame(data_dict, << "PCST", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    value = case frame_data do
      <<0, 0, 0, 0>> -> false
      _ -> true
    end

    parse_frame(data_dict |> Dict.put("podcast?", value), remaining_frame_data)
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

  def parse_frame(data_dict, << 0, 0, 0, 0, _remaining_frame_data::binary >>), do: data_dict
  def parse_frame(data_dict, <<>>), do: data_dict

  def parse_frame(data_dict, frame_data) do
    << frame_type::binary-size(4), _remaining_frame_data::binary >> = frame_data

    IO.puts "Unknown frame type #{inspect frame_type}"

    data_dict
  end

  ## APIC frame parsing
  defp parse_picture_frame(<< frame_encoding::unsigned-integer-size(8), remaining_data::binary >>) do
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

  # Comment frame parsing
  defp parse_comment_frame(<< 0, language::binary-size(3), comment_data::binary >>) do
    parse_comment_frame("ISO-8859-1", language, comment_data)
  end

  defp parse_comment_frame(<< 1, language::binary-size(3), comment_data::binary >>) do
    parse_comment_frame("UTF-8", language, comment_data)
  end

  defp parse_comment_frame(encoding, language, comment_data) do
    [short_description, actual_text | _] = comment_data |> StringUtils.decode_string |> String.split(<<0>>)

    %{}
    |> Dict.put("encoding", encoding)
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end
end
