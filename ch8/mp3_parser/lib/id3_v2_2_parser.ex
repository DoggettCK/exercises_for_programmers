defmodule ID3_v2_2_Parser do
  use Macros.ID3_v2_2

  text_frame "TAL", "Album/Movie/Show title"
  text_frame "TBP", "BPM (Beats Per Minute)"
  text_frame "TCM", "Composer"
  text_frame "TCO", "Content type"
  text_frame "TCR", "Copyright message"
  text_frame "TDA", "Date"
  text_frame "TDR", "Date Released"
  text_frame "TDS", "Podcast Description"
  text_frame "TDY", "Playlist delay"
  text_frame "TEN", "Encoded by"
  text_frame "TFT", "File type"
  text_frame "TID", "ID"
  text_frame "TIM", "Time"
  text_frame "TKE", "Initial key"
  text_frame "TLA", "Language(s)"
  text_frame "TLE", "Length"
  text_frame "TMT", "Media type"
  text_frame "TOA", "Original artist(s)/performer(s)"
  text_frame "TOF", "Original filename"
  text_frame "TOL", "Original Lyricist(s)/text writer(s)"
  text_frame "TOR", "Original release year"
  text_frame "TOT", "Original album/Movie/Show title"
  text_frame "TP1", "Lead artist(s)/Lead performer(s)/Soloist(s)/Performing group"
  text_frame "TP2", "Band/Orchestra/Accompaniment"
  text_frame "TP3", "Conductor/Performer refinement"
  text_frame "TP4", "Interpreted, remixed, or otherwise modified by"
  text_frame "TPA", "Part of a set"
  text_frame "TPB", "Publisher"
  text_frame "TRC", "ISRC (International Standard Recording Code)"
  text_frame "TRD", "Recording dates"
  text_frame "TRK", "Track number/Position in set"
  text_frame "TSI", "Size"
  text_frame "TSS", "Software/hardware and settings used for encoding"
  text_frame "TT1", "Content group description"
  text_frame "TT2", "Title/Songname/Content description"
  text_frame "TT3", "Subtitle/Description refinement"
  text_frame "TXT", "Lyricist/text writer"
  text_frame "TXX", "User defined text information frame"
  text_frame "TYE", "Year" 
  text_frame "WFD", "Podcast URL" 

  # iTunes custom tags
  text_frame "TSA", "album_sort"
  text_frame "TSC", "composer_sort"
  text_frame "TSP", "artist_sort"
  text_frame "TST", "title_sort"

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

  def parse_frame(data_dict, << "PCS", size::unsigned-integer-size(24), remaining_frame_data::binary >>) do
    << frame_data :: binary-size(size), remaining_frame_data :: binary >> = remaining_frame_data

    value = case frame_data do
      <<0, 0, 0, 0>> -> false
      _ -> true
    end
    
    parse_frame(data_dict |> Dict.put("podcast?", value), remaining_frame_data)
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
    [short_description, actual_text | _] = comment_data |> StringUtils.decode_string |> String.split(<<0>>)

    %{}
    |> Dict.put("encoding", "ISO-8859-1")
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end

  defp parse_comment_frame(<< 1, language::binary-size(3), comment_data::binary >>) do
    [short_description, actual_text | _] = comment_data |> StringUtils.decode_string |> String.split(<<0>>)

    %{}
    |> Dict.put("encoding", "UTF-8")
    |> Dict.put("language", language)
    |> Dict.put("short_description", short_description)
    |> Dict.put("text", actual_text)
  end
end
