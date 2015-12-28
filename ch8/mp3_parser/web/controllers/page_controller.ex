defmodule Mp3Parser.PageController do
  use Mp3Parser.Web, :controller


  def index(conn, _params) do
    render conn, "index.html"
  end

  def upload(conn, %{"file" => file} = params) do
    render(conn, "upload.json", file: file)
  end
end
