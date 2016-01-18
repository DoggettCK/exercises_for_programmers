defmodule OpenWeather do
  require URI

  def current_weather(location, format \\ :fahrenheit) do
    location
    |> URI.encode
    |> url_for_current_weather(Application.get_env(:weather, Weather.Endpoint) |> Keyword.get(:openweather_api_key))
    |> HTTPoison.get
    |> parse_response(format)
  end

  defp url_for_current_weather(encoded_location, app_id) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{encoded_location}&APPID=#{app_id}"
  end

  defp url_for_forecast(encoded_location, app_id) do
    "http://api.openweathermap.org/data/2.5/forecast?q=#{encoded_location}&APPID=#{app_id}"
  end

  defp icon_for(weather_icon_id) do
    "http://openweathermap.org/img/w/#{weather_icon_id}.png"
  end

  defp parse_wind_direction(wind_degrees) do
    index = wind_degrees
    |> round
    |> rem(360)
    |> (&(&1 / 22.5 + 0.5)).()
    |> Float.floor
    |> round
    |> rem(16)

    ["North",
      "North by Northeast",
      "Northeast",
      "East by Northeast",
      "East",
      "East by Southeast",
      "Southeast",
      "South by Southeast",
      "South",
      "South by Southwest",
      "Southwest",
      "West by Southwest",
      "West",
      "West by Northwest",
      "Northwest",
      "North by Northwest"]
    |> Enum.at(index)
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}, format) do
    body
    |> JSON.decode
    |> parse_current_weather(format)
  end

  defp parse_current_weather({:ok, json}, format) do
    temps = ["temp", "temp_max", "temp_min"]
            |> Enum.map(&(Dict.get(json["main"], &1) |> to_temperature(format) |> temperature_to_string))
            |> Enum.zip([:current, :max, :min])
            |> Enum.into(%{}, fn {k, v} -> {v, k} end)

    sun = ["sunrise", "sunset"]
          |> Enum.map(&({&1, Dict.get(json["sys"], &1)}))
          |> Enum.into(%{})

    location = json["name"]
    humidity = json["main"]["humidity"]
    pressure = json["main"]["pressure"]
    wind_degrees = json["wind"]["deg"]

    current_weather = json["weather"] |> hd

    %{
        temperature: temps,
        location: location,
        sun: sun,
        humidity: "#{humidity}%",
        pressure: "#{pressure} mbar",
        icon: current_weather |> Dict.get("icon") |> icon_for,
        conditions: current_weather |> Dict.get("description") |> String.capitalize,
        wind: %{ direction: wind_degrees |> parse_wind_direction }
      }
  end
  
  defp temperature_to_string({temp, sym}) do
    "#{temp |> Float.round(1)}°#{sym}" 
  end

  defp to_temperature(kelvin_temp, :celsius), do: {kelvin_temp - 273.15, "C"}
  defp to_temperature(kelvin_temp, :fahrenheit), do: {(kelvin_temp - 273.15) * 1.8 + 32, "F"}    
  defp to_temperature(kelvin_temp, _), do: {kelvin_temp, "K"}
end
