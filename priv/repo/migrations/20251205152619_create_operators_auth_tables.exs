defmodule Turnos.Repo.Migrations.CreateOperatorsAuthTables do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:operators) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :name, :string
      add :status, :string, default: "inactive", null: false

      timestamps()
    end

    create unique_index(:operators, [:email])
  end
end
