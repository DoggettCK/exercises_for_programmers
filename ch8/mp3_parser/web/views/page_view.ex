defmodule Mp3Parser.PageView do
  use Mp3Parser.Web, :view

  def render("upload.json", %{file: file}) do
    %{}
    |> Dict.put("content_type", file.content_type)
    |> Dict.put("filename", file.filename) 
    |> Dict.put("id3_tag", ID3Parser.parse(file.path))
  end
end
