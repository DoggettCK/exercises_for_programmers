defmodule Calculon.Repo.Migrations.CreateRate do
  use Ecto.Migration

  def change do
    create table(:rates) do
      add :name, :string
      add :in_usd, :float

      timestamps
    end

  end
end
