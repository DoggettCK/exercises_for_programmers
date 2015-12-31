defmodule Enums do
  ### Picture type
  for {val, desc} <- %{
    0x00 => "Other",
    0x01 => "32x32 pixels 'file icon' (PNG only)",
    0x02 => "Other file icon",
    0x03 => "Cover (front)",
    0x04 => "Cover (back)",
    0x05 => "Leaflet page",
    0x06 => "Media (e.g. label side of CD)",
    0x07 => "Lead artist/lead performer/soloist",
    0x08 => "Artist/performer",
    0x09 => "Conductor",
    0x0A => "Band/Orchestra",
    0x0B => "Composer",
    0x0C => "Lyricist/text writer",
    0x0D => "Recording Location",
    0x0E => "During recording",
    0x0F => "During performance",
    0x10 => "Movie/video screen capture",
    0x11 => "A bright coloured fish",
    0x12 => "Illustration",
    0x13 => "Band/artist logotype",
    0x14 => "Publisher/Studio logotype",
  } do
    def picture_type(unquote(val)), do: unquote(desc)
  end

  def picture_type(_), do: "Unknown picture type"

  ### Encoding
  for {val, desc} <- %{
    0x00 => "ISO-8859-1",
    0x01 => "UTF-8",
  } do
    def encoding(unquote(val)), do: unquote(desc)
  end

  def encoding(_), do: "Unknown encoding"
end
