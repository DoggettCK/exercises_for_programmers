defmodule Mp3Parser.Router do
  use Mp3Parser.Web, :router

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

  scope "/", Mp3Parser do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/gpd", PageController, :gpd
  end

  # Other scopes may use custom stacks.
   scope "/api", Mp3Parser do
     pipe_through :api

     post "/upload", Mp3Controller, :upload
     post "/gpd_upload", GpdController, :upload
   end
end
