defmodule Mp3Parser.PageControllerTest do
  use Mp3Parser.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
