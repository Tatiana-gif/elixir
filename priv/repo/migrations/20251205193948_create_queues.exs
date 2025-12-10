defmodule Turnos.Repo.Migrations.CreateQueues do
  use Ecto.Migration

  def change do
    # Drop if exists to handle duplicate table error
    drop_if_exists(index(:queues, [:operator_id]))
    drop_if_exists(table(:queues))

    create table(:queues) do
      add :number, :integer, null: false
      add :status, :string, null: false, default: "waiting"
      add :operator_id, references(:operators, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:queues, [:operator_id])
    create index(:queues, [:status])
    create unique_index(:queues, [:number])
  end
end
