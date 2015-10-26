defmodule Bmi.Router do
  use Bmi.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Bmi do
    pipe_through :api

    get "/bmi", BMIController, :bmi
  end
end
