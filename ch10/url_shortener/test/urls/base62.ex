defmodule UrlShortener.Base62Test do
  use ExUnit.Case

  test "decoder works correctly" do
    assert 125 = Base62.decode("cb")
    assert 19158 = Base62.decode("e9a")
  end

  test "encoder works correctly" do
    assert "cb" = Base62.encode(125)
    assert "e9a" = Base62.encode(19158)
  end
end
