defmodule Weather.WeatherController do
  use Weather.Web, :controller

  def current(conn, %{"location" => location, "units" => units}) do
    weather = OpenWeather.current_weather(location, units |> String.to_atom)

    render(conn, "location.json", weather: weather)
  end
end
