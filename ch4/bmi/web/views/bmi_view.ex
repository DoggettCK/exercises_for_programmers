defmodule Bmi.BMIView do
  use Bmi.Web, :view

  def render("bmi.json", %{bmi: bmi}) do
    bmi
  end
end
