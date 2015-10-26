defmodule Bmi.PageController do
  use Bmi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
