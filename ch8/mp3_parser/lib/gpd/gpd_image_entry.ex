defmodule GpdImageEntry do
  defstruct id: nil, data: nil

  def parse_entry(%GpdEntry{length: len, id: id}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    image = %GpdImageEntry{id: id, data: "data:image/png;base64,#{:base64.encode(entry_data)}"}

    %Gpd{ gpd | images: [image | gpd.images], remaining_data: remaining_data }
  end
end
