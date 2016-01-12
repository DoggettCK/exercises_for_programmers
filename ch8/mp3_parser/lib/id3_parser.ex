defmodule ID3Parser do
  def parse(file_name) do
    case File.read(file_name) do
      {:ok, mp3} ->

        << "ID3",
        id3_version :: unsigned-integer-size(8),
        _id3_revision :: binary-size(1),
        _flags :: binary-size(1),
        id3_tag_size :: unsigned-integer-size(32),
        tag_and_mp3 :: binary >> = mp3

        # Until Erlang itself allows function calls/variables
        # inside binary pattern matching, have to split it up
        # into two matches with the math done in the middle
        id3_tag_size = SynchSafe.unsynchsafe(id3_tag_size)

        << id3_tag :: binary-size(id3_tag_size),
        _mp3_data :: binary >> = tag_and_mp3

        parse(id3_version, id3_tag)
      _ ->
        IO.puts "Couldn't open #{file_name}"
    end
  end

  def parse(2, id3_tag) do
    # http://id3.org/id3v2-00
    ID3_v2_2_Parser.parse_frame(%{} |> Dict.put("id3_version", 2), id3_tag)
  end

  def parse(3, id3_tag) do
    # http://id3.org/id3v2.3.0
    ID3_v2_3_Parser.parse_frame(%{} |> Dict.put("id3_version", 3), id3_tag)
  end

  def parse(4, id3_tag) do
    # http://id3.org/id3v2.4.0-frames
    ID3_v2_4_Parser.parse_frame(%{} |> Dict.put("id3_version", 4), id3_tag)
  end
end
