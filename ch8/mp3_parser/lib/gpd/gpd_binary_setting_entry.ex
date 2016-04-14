defmodule GpdBinarySettingEntry do
  defstruct id: nil, data: nil

  def parse(id, data), do: %GpdBinarySettingEntry{id: id, data: data}
end
