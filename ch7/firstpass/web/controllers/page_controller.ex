defmodule Firstpass.PageController do
  use Firstpass.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
