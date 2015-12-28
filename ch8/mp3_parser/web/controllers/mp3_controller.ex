defmodule Mp3Parser.Mp3Controller do
  use Mp3Parser.Web, :controller

  def upload(conn, %{"file" => file} = params) do
    render(conn, "upload.json", file: file)
  end
end
