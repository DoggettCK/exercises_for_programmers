defmodule UrlShortener.UrlControllerTest do
  use UrlShortener.ConnCase

  alias UrlShortener.Url
  @valid_attrs %{ip: "some content", url: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, url_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing urls"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, url_path(conn, :new)
    assert html_response(conn, 200) =~ "New url"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, url_path(conn, :create), url: @valid_attrs
    assert redirected_to(conn) == url_path(conn, :index)
    assert Repo.get_by(Url, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, url_path(conn, :create), url: @invalid_attrs
    assert html_response(conn, 200) =~ "New url"
  end

  test "shows chosen resource", %{conn: conn} do
    url = Repo.insert! %Url{}
    conn = get conn, url_path(conn, :show, url)
    assert html_response(conn, 200) =~ "Show url"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, url_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    url = Repo.insert! %Url{}
    conn = get conn, url_path(conn, :edit, url)
    assert html_response(conn, 200) =~ "Edit url"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    url = Repo.insert! %Url{}
    conn = put conn, url_path(conn, :update, url), url: @valid_attrs
    assert redirected_to(conn) == url_path(conn, :show, url)
    assert Repo.get_by(Url, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    url = Repo.insert! %Url{}
    conn = put conn, url_path(conn, :update, url), url: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit url"
  end

  test "deletes chosen resource", %{conn: conn} do
    url = Repo.insert! %Url{}
    conn = delete conn, url_path(conn, :delete, url)
    assert redirected_to(conn) == url_path(conn, :index)
    refute Repo.get(Url, url.id)
  end
end
