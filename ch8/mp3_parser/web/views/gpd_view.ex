defmodule Mp3Parser.GpdView do
  use Mp3Parser.Web, :view

  def render("upload.json", %{file: file}) do
    %{
      gpd_id: Path.rootname(file.filename),
      gpd: GpdParser.parse(file.path)
    }
  end
end
