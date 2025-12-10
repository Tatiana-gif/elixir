defmodule Turnos.Repo.Migrations.AddModuleToQueues do
  use Ecto.Migration

  def change do
    alter table(:queues) do
      add :module, :string, default: "Sin asignar"
    end
  end
end
