defmodule GpdImageEntry do
  defstruct id: nil, data: nil

  def parse(id, image_data), do: %GpdImageEntry{id: id, data: "data:image/png;base64,#{:base64.encode(image_data)}"}
end
