defmodule UrlShortener.UrlTest do
  use UrlShortener.ModelCase

  alias UrlShortener.Url

  @valid_attrs %{ip: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Url.changeset(%Url{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Url.changeset(%Url{}, @invalid_attrs)
    refute changeset.valid?
  end
end
