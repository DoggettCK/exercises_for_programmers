defmodule ID3_v2_4_Parser do
  def parse_frame(data_dict, << "TALB", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("album", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSOA", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("album_sort_order", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSOP", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("performer_sort_order", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSOT", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("title_sort_order", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSO2", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("album_artist_sort_order", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TXXX", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    user_defined_text = [parse_user_defined_text_frame(frame_data) | data_dict |> Dict.get("user_defined_text", [])]

    parse_frame(data_dict |> Dict.put("user_defined_text", user_defined_text), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE1", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("lead_performer", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE2", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("band", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE3", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("conductor", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE4", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("interpreter", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIT1", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("content_group_description", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIT2", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("title_description", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIT3", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("subtitle_refinement", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TRCK", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("track_number", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "USLT", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data
    << encoding::binary-size(1), language::binary-size(3), descriptor_text::binary >> = frame_data

    [descriptor, text] = descriptor_text |> String.split(<<0>>, parts: 2) |> Enum.map(&(encoding <> &1)) |> Enum.map(&StringUtils.decode_string/1)

    transcription = %{}
    |> Dict.put("language", language)
    |> Dict.put("descriptor", descriptor)
    |> Dict.put("text", text)

    parse_frame(data_dict |> Dict.put("unsynchronized_lyrics_transcription", transcription), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TMOO", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("mood", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TDRC", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("recording_time", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "WOAR", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    # NOTE: Doesn't have an encoding on it
    parse_frame(data_dict |> Dict.put("official_artist_webpage", frame_data), remaining_frame_data)
  end

  def parse_frame(data_dict, << "WOAF", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    # NOTE: Doesn't have an encoding on it
    parse_frame(data_dict |> Dict.put("official_audio_file_webpage", frame_data), remaining_frame_data)
  end

  def parse_frame(data_dict, << "WCOM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    # NOTE: Doesn't have an encoding on it
    parse_frame(data_dict |> Dict.put("commercial_information", frame_data), remaining_frame_data)
  end

  def parse_frame(data_dict, << "WPUB", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    # NOTE: Doesn't have an encoding on it
    parse_frame(data_dict |> Dict.put("publishers_official_webpage", frame_data), remaining_frame_data)
  end

  def parse_frame(data_dict, << "WORS", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    # NOTE: Doesn't have an encoding on it
    parse_frame(data_dict |> Dict.put("official_radio_station_webpage", frame_data), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TMCL", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("musician_credits_list", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TOAL", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("original_title", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TOPE", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("original_artist", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TOFN", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("original_filename", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TOLY", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("original_lyricist", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TDOR", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("original_release_time", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPUB", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("publisher", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TDRL", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("release_time", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "POPM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    [email_to_user, << rating::unsigned-integer-size(8), counter::binary >>] = frame_data |> String.split(<<0>>, parts: 2)

    popularimeter = %{}
    |> Dict.put("email_to_user", email_to_user)
    |> Dict.put("rating", rating)
    |> Dict.put("counter", counter)

    parse_frame(data_dict |> Dict.put("popularimeter", popularimeter), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TCOP", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("copyright", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPOS", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("part_of_set", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TENC", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("encoded_by", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSSE", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("encoding_settings", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSST", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("set_subtitle", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TOWN", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("file_owner", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TCON", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("content_type", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIPL", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("involved_people", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSRC", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("international_standard_recording_code", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TLAN", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("language", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TEXT", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("lyricist", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TMED", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("media_type", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TCMP", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    # Unofficial tag
    parse_frame(data_dict |> Dict.put("iTunes Compilation Flag", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TBPM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("beats_per_minute", frame_data |> StringUtils.decode_string |> String.to_integer), remaining_frame_data)
  end

  def parse_frame(data_dict, << "COMM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    comments = [parse_comment_frame(frame_data) | data_dict |> Dict.get("comments", [])]

    parse_frame(data_dict |> Dict.put("comments", comments), remaining_frame_data)
  end

  def parse_frame(data_dict, << "APIC", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    # NOTE: tagtest.ID3v2.4.mp3 actually has flags set indicating frame has been unsynchronized and a data length indicator has been added to the frame, but spec doesn't say how to deal with it
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    pictures = [parse_picture_frame(frame_data) | data_dict |> Dict.get("pictures", [])]

    parse_frame(data_dict |> Dict.put("pictures", pictures), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TCOM", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("composer", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TSTU", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("recording_studio", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPRO", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    us_size = SynchSafe.unsynchsafe(size)

    << frame_data::binary-size(us_size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("produced_notice", frame_data |> StringUtils.decode_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << 0, 0, 0, 0, _remaining_frame_data::binary >>) do
    data_dict
  end

  def parse_frame(data_dict, << frame_type::binary-size(4), _::binary >>) do
    IO.puts "Unknown frame type #{inspect frame_type}"

    data_dict
  end

  def parse_frame(data_dict, <<>>) do
    data_dict
  end


  ### APIC frame parsing
  defp parse_picture_frame(frame_data) do
    << _data_length::unsigned-integer-size(32), frame_encoding::unsigned-integer-size(8), remaining_data::binary >> = frame_data
    # data_length appears to be a synchsafed int that is close to the frame size, but off in either direction

    [mime_type, << picture_type::unsigned-integer-size(8), remaining_data::binary >>] = remaining_data |> String.split(<<0>>, parts: 2)

    [description, picture_data] = (remaining_data |> String.split(<<0>>, parts: 2))

    %{}
    |> Dict.put("encoding", Enums.encoding(frame_encoding))
    |> Dict.put("picture_type", Enums.picture_type(picture_type))
    |> Dict.put("description", (<<frame_encoding>> <> description) |> StringUtils.decode_string)
    |> Dict.put("mime_type", mime_type)
    |> Dict.put("image", image_data_url(mime_type, picture_data))
  end

  defp image_data_url(mime_type, picture_data) do
    "data:#{mime_type};base64,#{:base64.encode(picture_data)}"
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

  defp parse_comment_frame(<< 3, language::binary-size(3), comment_data::binary >>) do
    # Reattach the encoding so the decoder can parse them correctly
    [short_description, actual_text | _] = comment_data 
                                            |> String.split(<<0>>)
                                            |> Enum.map(&(<<3>> <> &1))
                                            |> Enum.map(&StringUtils.decode_string/1)

    %{}
    |> Dict.put("encoding", "UTF-8")
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end

  # User-defined text parsing
  defp parse_user_defined_text_frame(<< encoding::binary-size(1), description_value::binary >>) do
    # Reattach the encoding so the decoder can parse them correctly
    [description, value] = description_value 
                            |> String.split(<<0>>)
                            |> Enum.map(&(encoding <> &1))
                            |> Enum.map(&StringUtils.decode_string/1)

    %{}
    |> Dict.put("description", description)
    |> Dict.put("value", value)
  end
end
