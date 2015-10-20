defmodule Calculon.RateController do
  use Calculon.Web, :controller

  alias Calculon.Rate

  plug :scrub_params, "rate" when action in [:create, :update]

  def index(conn, _params) do
    rates = Repo.all(from r in Rate, select: {r.name, r.id})
    render(conn, "index.html", rates: rates)
  end

  def create(conn, %{"rate" => %{"amount" => amount, 
                                 "from" => from_rate, 
                                 "to" => to_rate}}) do
    {amount_f, _} = Float.parse(amount)

    [rate_from, name_from] = Repo.one(from r in Rate, 
                                      where: r.id == ^from_rate, 
                                      select: [r.in_usd, r.name])
    [rate_to, name_to] = Repo.one(from r in Rate, 
                                  where: r.id == ^to_rate, 
                                  select: [r.in_usd, r.name])

    converted_amount = convert(amount_f, rate_from, rate_to)
  
    conn
    |> put_flash(:info, "#{amount} #{name_from} => #{converted_amount} #{name_to}")
    |> redirect(to: rate_path(conn, :index))
  end

  defp convert(amount_from, rate_from, rate_to) do
    Float.round ((amount_from * rate_to) / rate_from), 2
  end
end
