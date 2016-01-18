defmodule GpdTest do
  use ExUnit.Case

  test "MS filetime stamp converter works properly" do
    assert 1452874705000 == TimeUtils.filetime_to_datetime(130973483050000000)
    assert 130973483050000000 == TimeUtils.datetime_to_filetime(1452874705000)
  end
end
