defmodule ID3Parser do
  def parse(file_name) do
    case File.read(file_name) do
      {:ok, mp3} ->

        << id3_header :: binary-size(10), mp3_data :: binary >> = mp3

        << "ID3",
        id3_version :: binary-size(2),
        _unsynchronization :: size(1),
        _extended_header :: size(1),
        _experimental :: size(1),
        0 :: size(5),
        id3_tag_size :: unsigned-integer-size(32) >> = id3_header

        parse(id3_version, SynchSafe.unsynchsafe(id3_tag_size), mp3_data)
      _ ->
        IO.puts "Couldn't open #{file_name}"
    end
  end

  def parse(<<3, _>>, id3_tag_size, mp3_data) do
    << id3_tag :: binary-size(id3_tag_size), _ :: binary >> = mp3_data

    parse_frame(%{}, id3_tag)
  end

  def parse_frame(data_dict, << "TCON", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("content_type", frame_data |> StringUtils.clean_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TYER", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("year", frame_data |> StringUtils.clean_string |> String.to_integer), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TIT2", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("title", frame_data |> StringUtils.clean_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "TPE1", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("lead_performer", frame_data |> StringUtils.clean_string), remaining_frame_data)
  end

  def parse_frame(data_dict, << "APIC", size::unsigned-integer-size(32), _flags::binary-size(2), remaining_frame_data::binary >>) do
    << frame_data::binary-size(size), remaining_frame_data::binary >> = remaining_frame_data

    parse_frame(data_dict |> Dict.put("pictures", parse_apic_frame(frame_data)), remaining_frame_data)
  end

  def parse_frame(data_dict, << 0, 0, 0, 0, _::binary-size(6), remaining_frame_data::binary >>) do
    parse_frame(data_dict, remaining_frame_data)
  end

  def parse_frame(data_dict, <<>>) do
    data_dict
  end

  def parse_frame(data_dict, frame_data) do
    << frame_type::binary-size(4), _size::binary-size(6), remaining_frame_data::binary >> = frame_data

    IO.puts "Unknown frame type #{inspect frame_type}"

    parse_frame(data_dict, remaining_frame_data)
  end

  ### APIC frame parsing
  defp parse_apic_frame(frame_data) do
    << frame_encoding::unsigned-integer-size(8), remaining_data::binary >> = frame_data

    {mime_type, remaining_data} = StringUtils.read_null_terminated_string(remaining_data)

    << picture_type::unsigned-integer-size(8), remaining_data::binary >> = remaining_data

    {description, remaining_data} = StringUtils.read_null_terminated_string(remaining_data)

    # TODO: Do something with remaining_data (base64 it into JSON)
    %{
      "encoding": encoding(frame_encoding),
      "mime_type": mime_type,
      "picture_type": picture_type(picture_type),
      "picture_description": description,
    }
  end

  ### Picture type
  defp picture_type(0x00), do: "Other"
  defp picture_type(0x01), do: "32x32 pixels 'file icon' (PNG only)"
  defp picture_type(0x02), do: "Other file icon"
  defp picture_type(0x03), do: "Cover (front)"
  defp picture_type(0x04), do: "Cover (back)"
  defp picture_type(0x05), do: "Leaflet page"
  defp picture_type(0x06), do: "Media (e.g. lable side of CD)"
  defp picture_type(0x07), do: "Lead artist/lead performer/soloist"
  defp picture_type(0x08), do: "Artist/performer"
  defp picture_type(0x09), do: "Conductor"
  defp picture_type(0x0A), do: "Band/Orchestra"
  defp picture_type(0x0B), do: "Composer"
  defp picture_type(0x0C), do: "Lyricist/text writer"
  defp picture_type(0x0D), do: "Recording Location"
  defp picture_type(0x0E), do: "During recording"
  defp picture_type(0x0F), do: "During performance"
  defp picture_type(0x10), do: "Movie/video screen capture"
  defp picture_type(0x11), do: "A bright coloured fish"
  defp picture_type(0x12), do: "Illustration"
  defp picture_type(0x13), do: "Band/artist logotype"
  defp picture_type(0x14), do: "Publisher/Studio logotype"

  ### Encoding
  defp encoding(0), do: "ISO-8859-1"
  defp encoding(1), do: "UTF-8"
end
