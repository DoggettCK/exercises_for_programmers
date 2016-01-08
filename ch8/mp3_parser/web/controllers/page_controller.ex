defmodule Mp3Parser.PageController do
  use Mp3Parser.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def gpd(conn, _params) do
    render conn, "gpd.html"
  end
end
