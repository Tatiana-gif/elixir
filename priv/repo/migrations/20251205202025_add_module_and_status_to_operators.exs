defmodule Turnos.Repo.Migrations.AddModuleAndStatusToOperators do
  use Ecto.Migration

  def change do
    alter table(:operators) do
      add :module, :string, default: "Sin asignar"
      add :online_status, :string, default: "offline"
      add :last_seen_at, :naive_datetime
    end
  end
end
