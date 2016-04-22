defmodule TimeUtils do
  epoch = {{1970, 1, 1}, {0, 0, 0}}
  @epoch_seconds :calendar.datetime_to_gregorian_seconds(epoch)

  def filetime_to_datetime(filetime) do
    div(filetime - ms_filetime_offset, 10000)
  end

  def datetime_to_filetime(datetime) do
    ms_filetime_offset + (datetime * 10000)
  end
  
  defp ms_filetime_offset, do: 116444736000000000

  def to_human_readable(filetime) do
    datetime = filetime_to_datetime(filetime)

    milliseconds = rem(datetime, 1000)
    seconds = div(datetime, 1000)

    {{year, month, day}, {hour, minute, second}} = :calendar.gregorian_seconds_to_datetime(seconds + @epoch_seconds)

    "#{pad_left(year, 4)}-#{pad_left(month, 2)}-#{pad_left(day, 2)} #{pad_left(hour, 2)}:#{pad_left(minute, 2)}:#{pad_left(second, 2)}.#{pad_left(milliseconds, 3)}"
  end

  defp pad_left(int, min_length, pad \\ ?0, base \\ 10) do
    int
    |> Integer.to_string(base)
    |> String.rjust(min_length, pad)
  end
end
