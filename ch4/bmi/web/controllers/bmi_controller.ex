defmodule Bmi.BMIController do
  use Bmi.Web, :controller

  @invalid_bmi %{bmi: nil, status: :invalid}

  def bmi(conn, %{"weight" => weight, "height" => height, "style" => style}) when is_binary(weight) and is_binary(height) do
    {weight, _} = Integer.parse(weight)
    {height, _} = Integer.parse(height)
    
    conn |> bmi(%{"weight": weight, "height": height, "style": style})
  end

  def bmi(conn, %{"weight" => weight, "height" => height, "style" => style}) do
    bmi = calculate_bmi(weight, height, style)
    render(conn, "bmi.json", bmi: bmi)
  end

  def bmi(conn, _params) do
    render(conn, "bmi.json", bmi: @invalid_bmi)
  end
  
  defp calculate_bmi(pounds, inches, :imperial) do
    (pounds / (inches * inches)) * 703
  end

  defp calculate_bmi(kilograms, centimeters, :metric) do
    calculate_bmi(kilograms * 2.20462, centimeters * 0.393701, :imperial) 
  end

  defp calculate_bmi(weight, height, style) do
    case {weight, height, String.downcase(style)} do
      {weight, height, "imperial"} ->
        calculate_bmi(weight, height, :imperial) |> bmi_healthy?
      {weight, height, "metric"} ->
        calculate_bmi(weight, height, :metric) |> bmi_healthy?
      _ -> 
        @invalid_bmi
    end
  end

  defp bmi_healthy?(bmi) do
    cond do
      bmi < 18.5 -> %{bmi: bmi, status: :underweight}
      bmi > 25 -> %{bmi: bmi, status: :overweight}
      true -> %{bmi: bmi, status: :ideal}
    end
  end
end
