defmodule ID3Parser do
  def parse(file_name) do
    case File.read(file_name) do
      {:ok, mp3} ->

        << id3_header :: binary-size(10), mp3_data :: binary >> = mp3

        << "ID3",
        id3_version :: binary-size(2),
        _flags :: binary-size(1),
        id3_tag_size :: unsigned-integer-size(32) >> = id3_header

        parse(id3_version, SynchSafe.unsynchsafe(id3_tag_size), mp3_data)
      _ ->
        IO.puts "Couldn't open #{file_name}"
    end
  end

  def parse(<<2, _>>, id3_tag_size, mp3_data) do
    << id3_tag :: binary-size(id3_tag_size), _ :: binary >> = mp3_data

    ID3_v2_2_Parser.parse_frame(%{}, id3_tag)
  end

  def parse(<<3, _>>, id3_tag_size, mp3_data) do
    << id3_tag :: binary-size(id3_tag_size), _ :: binary >> = mp3_data

    ID3_v2_3_Parser.parse_frame(%{}, id3_tag)
  end

end
