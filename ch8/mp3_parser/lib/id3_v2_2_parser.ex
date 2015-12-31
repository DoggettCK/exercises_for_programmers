defmodule ID3_v2_2_Parser do
  def parse_frame(data_dict, << "TSS", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("encoding_settings", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "COM", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    comments = [parse_comment_frame(frame_data) | data_dict |> Dict.get("comments", [])]

    parse_frame(data_dict |> Dict.put("comments", comments), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TDA", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("date", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIM", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("time", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TYE", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("year", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TBP", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("beats_per_minute", frame_data |> StringUtils.decode_string |> String.to_integer), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "PIC", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    pictures = [parse_picture_frame(frame_data) | data_dict |> Dict.get("pictures", [])]

    parse_frame(data_dict |> Dict.put("pictures", pictures), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TT2", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("title", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TP1", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("lead_performer", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TCM", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("composer", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TAL", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("album", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TST", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    # iTunes custom tag
    parse_frame(data_dict |> Dict.put("title_sort", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TSA", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    # iTunes custom tag
    parse_frame(data_dict |> Dict.put("album_sort", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end
  
  def parse_frame(data_dict, << "TSP", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    # iTunes custom tag
    parse_frame(data_dict |> Dict.put("artist_sort", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSC", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    # iTunes custom tag
    parse_frame(data_dict |> Dict.put("composer_sort", frame_data |> StringUtils.decode_string), remaining_frame_data)
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
  defp parse_picture_frame(<<0, image_format::binary-size(3), picture_type::unsigned-integer-size(8), remaining_data::binary>> = frame_data) do
    [description, picture_data] = remaining_data |> String.split(<<0>>, parts: 2)

    %{}
    |> Dict.put("encoding", "ISO-8859-1")
    |> Dict.put("image_format", image_format)
    |> Dict.put("picture_type", Enums.picture_type(picture_type))
    |> Dict.put("picture_description", description)
    |> Dict.put("image", "data:image/#{image_format |> String.downcase};base64,#{:base64.encode(picture_data)}")
  end

  ### Comment frame parsing
  defp parse_comment_frame(<< 0, language::binary-size(3), comment_data::binary >> = frame_data) do
    [short_description, actual_text | _] = comment_data |> String.split(<<0>>)

    %{}
    |> Dict.put("encoding", "ISO-8859-1")
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end

  defp parse_comment_frame(<< 1, language::binary-size(3), comment_data::binary >> = frame_data) do
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
