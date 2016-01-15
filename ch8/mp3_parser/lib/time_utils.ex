defmodule TimeUtils do

  def filetime_to_datetime(filetime) do
    div(filetime - ms_filetime_offset, 10000)
  end

  def datetime_to_filetime(datetime) do
    ms_filetime_offset + (datetime * 10000)
  end
  
  defp ms_filetime_offset, do: 116444736000000000
end
