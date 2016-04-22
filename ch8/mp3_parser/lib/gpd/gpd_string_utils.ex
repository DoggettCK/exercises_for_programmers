defmodule GpdStringUtils do
  def split_null_terminated(data, count, pad \\ "") do
    :unicode.encoding_to_bom({:utf16, :big})
    |> Kernel.<>(data)
    |> StringUtils.decode_string
    |> String.split(<<0>>, trim: true)
    |> Enum.concat(Stream.cycle([pad]) |> Enum.take(count))
    |> Enum.take(count)
  end
end
