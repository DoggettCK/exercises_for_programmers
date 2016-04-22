defmodule GpdStringEntry do
  @title_information 0x8000

  def parse_entry(%GpdEntry{id: @title_information, length: len}, %Gpd{remaining_data: data} = gpd) do
    << entry_data::binary-size(len), remaining_data::binary >> = data

    [title] = GpdStringUtils.split_null_terminated(entry_data, 1)

    %Gpd{ gpd | title: title, remaining_data: remaining_data }
  end
end
