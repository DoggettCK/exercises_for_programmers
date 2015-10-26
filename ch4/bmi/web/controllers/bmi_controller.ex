defmodule Bmi.BMIController do
  use Bmi.Web, :controller

  def bmi(conn, %{"weight" => weight, "height" => height, "style" => style}) do
    bmi = calculate_bmi(weight, height, style)
    render(conn, "bmi.json", bmi: bmi)
  end

  defp calculate_bmi(pounds, inches, :imperial) do
    (pounds / (inches * inches)) * 703
  end

  defp calculate_bmi(kilograms, centimeters, :metric) do
    calculate_bmi(kilograms * 2.20462, centimeters * 0.393701, :imperial) 
  end

  defp calculate_bmi(weight, height, style) do
    {weight, _} = Integer.parse(weight)
    {height, _} = Integer.parse(height)

    case {weight, height, style} do
      {weight, height, "Imperial"} ->
        calculate_bmi(weight, height, :imperial) |> bmi_healthy?
      {weight, height, "Metric"} ->
        calculate_bmi(weight, height, :metric) |> bmi_healthy?
      true -> 
        {nil, :invalid}
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
