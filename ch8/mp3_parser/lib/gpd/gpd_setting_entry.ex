defmodule GpdSettingEntry do
  defstruct id: nil, last_edited: nil, unknown: nil, data_type: nil, data: nil, remaining: nil

  @data_types %{
    context: 0,
    int32: 1,
    int64: 2,
    double: 3,
    unicode_string: 4,
    float: 5,
    binary: 6,
    datetime: 7,
    null: 0xFF
  }

  for {key, value} <- @data_types do
    defp data_type(unquote(value)), do: unquote(key)
  end

  def parse(data) do
    <<id::signed-integer-size(32),
    last_edited::unsigned-integer-size(16),
    unknown::unsigned-integer-size(16),
    type::unsigned-integer-size(8),
    _::binary-size(7),
    remaining::binary>> = data

    %GpdSettingEntry{
      id: id,
      last_edited: last_edited,
      unknown: unknown,
      data_type: data_type(type),
      data: parse_data_by_type(remaining, data_type(type))
    }
  end

  defp parse_data_by_type(<<int32::unsigned-integer-size(32), _::binary>> = data, :int32), do: int32
  defp parse_data_by_type(<<int64::unsigned-integer-size(64), _::binary>> = data, :int64), do: int64
end
