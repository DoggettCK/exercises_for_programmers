defmodule Enums do
  ### Picture type
  def picture_type(0x00), do: "Other"
  def picture_type(0x01), do: "32x32 pixels 'file icon' (PNG only)"
  def picture_type(0x02), do: "Other file icon"
  def picture_type(0x03), do: "Cover (front)"
  def picture_type(0x04), do: "Cover (back)"
  def picture_type(0x05), do: "Leaflet page"
  def picture_type(0x06), do: "Media (e.g. label side of CD)"
  def picture_type(0x07), do: "Lead artist/lead performer/soloist"
  def picture_type(0x08), do: "Artist/performer"
  def picture_type(0x09), do: "Conductor"
  def picture_type(0x0A), do: "Band/Orchestra"
  def picture_type(0x0B), do: "Composer"
  def picture_type(0x0C), do: "Lyricist/text writer"
  def picture_type(0x0D), do: "Recording Location"
  def picture_type(0x0E), do: "During recording"
  def picture_type(0x0F), do: "During performance"
  def picture_type(0x10), do: "Movie/video screen capture"
  def picture_type(0x11), do: "A bright coloured fish"
  def picture_type(0x12), do: "Illustration"
  def picture_type(0x13), do: "Band/artist logotype"
  def picture_type(0x14), do: "Publisher/Studio logotype"

  ### Encoding
  def encoding(0), do: "ISO-8859-1"
  def encoding(1), do: "UTF-8"
end
