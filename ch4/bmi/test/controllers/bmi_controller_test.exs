defmodule Bmi.BMIControllerTest do
  use Bmi.ConnCase

  alias Bmi.BMI
  @valid_attrs %{}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, bmi_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    bmi = Repo.insert! %BMI{}
    conn = get conn, bmi_path(conn, :show, bmi)
    assert json_response(conn, 200)["data"] == %{"id" => bmi.id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, bmi_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, bmi_path(conn, :create), bmi: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(BMI, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, bmi_path(conn, :create), bmi: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    bmi = Repo.insert! %BMI{}
    conn = put conn, bmi_path(conn, :update, bmi), bmi: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(BMI, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    bmi = Repo.insert! %BMI{}
    conn = put conn, bmi_path(conn, :update, bmi), bmi: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    bmi = Repo.insert! %BMI{}
    conn = delete conn, bmi_path(conn, :delete, bmi)
    assert response(conn, 204)
    refute Repo.get(BMI, bmi.id)
  end
end
