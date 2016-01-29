defmodule UrlShortener.Repo.Migrations.CreateUrl do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :url, :string, size: 255
      add :ip, :string, size: 39

      timestamps
    end

  end
end
