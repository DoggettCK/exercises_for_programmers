defmodule ID3_v2_2_Parser do
  use Macros.ID3_v2_2

  text_frame "TAL", "album"
  text_frame "TCM", "composer"
  text_frame "TDA", "date"
  text_frame "TIM", "time"
  text_frame "TP1", "lead_performer"
  text_frame "TSS", "encoding_settings"
  text_frame "TT2", "title"
  text_frame "TYE", "year"
  
  # iTunes custom tags
  text_frame "TSA", "album_sort"
  text_frame "TSC", "composer_sort"
  text_frame "TSP", "artist_sort"
  text_frame "TST", "title_sort"

  integer_frame "TBP", "beats_per_minute"

  def parse_frame(data_dict, << "COM", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    comments = [parse_comment_frame(frame_data) | data_dict |> Dict.get("comments", [])]

    parse_frame(data_dict |> Dict.put("comments", comments), remaining_frame_data)
  end

  def parse_frame(data_dict, << "PIC", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    pictures = [parse_picture_frame(frame_data) | data_dict |> Dict.get("pictures", [])]

    parse_frame(data_dict |> Dict.put("pictures", pictures), remaining_frame_data)
  end

  def parse_frame(data_dict, << 0, 0, 0, _::binary >>) do
    # Null tag means there's nothing left
    data_dict
  end

  def parse_frame(data_dict, <<>>) do
    data_dict
  end

  def parse_frame(data_dict, << frame_type::binary-size(3), _::binary >>) do
    IO.puts "Unknown frame type #{frame_type}"

    data_dict
  end

  ### APIC frame parsing
  defp parse_picture_frame(<<0, image_format::binary-size(3), picture_type::unsigned-integer-size(8), remaining_data::binary>>) do
    [description, picture_data] = remaining_data |> String.split(<<0>>, parts: 2)

    %{}
    |> Dict.put("encoding", "ISO-8859-1")
    |> Dict.put("image_format", image_format)
    |> Dict.put("picture_type", Enums.picture_type(picture_type))
    |> Dict.put("picture_description", description)
    |> Dict.put("image", "data:image/#{image_format |> String.downcase};base64,#{:base64.encode(picture_data)}")
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
