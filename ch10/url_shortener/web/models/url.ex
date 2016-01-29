defmodule UrlShortener.Url do
  use UrlShortener.Web, :model

  schema "urls" do
    field :url, :string
    field :ip, :string

    timestamps
  end

  @required_fields ~w(url ip)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:url, min: 6)
    |> validate_length(:url, max: 255)
    |> validate_length(:ip, min: 7)
    |> validate_length(:ip, max: 39)
  end
end
