defmodule Calculon.RateControllerTest do
  use Calculon.ConnCase

  alias Calculon.Rate
  @valid_attrs %{in_usd: "120.5", name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, rate_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing rates"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, rate_path(conn, :new)
    assert html_response(conn, 200) =~ "New rate"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, rate_path(conn, :create), rate: @valid_attrs
    assert redirected_to(conn) == rate_path(conn, :index)
    assert Repo.get_by(Rate, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, rate_path(conn, :create), rate: @invalid_attrs
    assert html_response(conn, 200) =~ "New rate"
  end

  test "shows chosen resource", %{conn: conn} do
    rate = Repo.insert! %Rate{}
    conn = get conn, rate_path(conn, :show, rate)
    assert html_response(conn, 200) =~ "Show rate"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, rate_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    rate = Repo.insert! %Rate{}
    conn = get conn, rate_path(conn, :edit, rate)
    assert html_response(conn, 200) =~ "Edit rate"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    rate = Repo.insert! %Rate{}
    conn = put conn, rate_path(conn, :update, rate), rate: @valid_attrs
    assert redirected_to(conn) == rate_path(conn, :show, rate)
    assert Repo.get_by(Rate, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    rate = Repo.insert! %Rate{}
    conn = put conn, rate_path(conn, :update, rate), rate: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit rate"
  end

  test "deletes chosen resource", %{conn: conn} do
    rate = Repo.insert! %Rate{}
    conn = delete conn, rate_path(conn, :delete, rate)
    assert redirected_to(conn) == rate_path(conn, :index)
    refute Repo.get(Rate, rate.id)
  end
end
