defmodule Turnos.Repo.Migrations.AddOperatorsTokens do
  use Ecto.Migration

  def change do
    create table(:operators_tokens) do
      add :operator_id, references(:operators, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(updated_at: false)
    end

    create index(:operators_tokens, [:operator_id])
    create unique_index(:operators_tokens, [:context, :token])
  end
end
