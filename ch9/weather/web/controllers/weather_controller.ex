defmodule Weather.WeatherController do
  use Weather.Web, :controller

  def current(conn, %{"location" => location, "format" => format}) do
    weather = OpenWeather.current_weather(location, format |> String.to_atom)

    render(conn, "location.json", weather: weather)
  end
end
