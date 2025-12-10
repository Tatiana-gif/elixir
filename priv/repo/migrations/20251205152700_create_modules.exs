defmodule Turnos.Repo.Migrations.CreateModules do
  use Ecto.Migration

  def change do
    create table(:modules) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:modules, [:name])
  end
end
