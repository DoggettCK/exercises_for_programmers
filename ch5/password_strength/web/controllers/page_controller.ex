defmodule PasswordStrength.PageController do
  use PasswordStrength.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
