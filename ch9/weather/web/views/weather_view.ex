defmodule Weather.WeatherView do
  use Weather.Web, :view

  def render("location.json", %{weather: weather}) do
    weather
  end
end
