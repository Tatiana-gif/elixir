defmodule Turnos.Repo.Migrations.AddCompletedAtToQueues do
  use Ecto.Migration

  def change do
    alter table(:queues) do
      add :completed_at, :utc_datetime, null: true
    end

    create index(:queues, [:completed_at])
  end
end
