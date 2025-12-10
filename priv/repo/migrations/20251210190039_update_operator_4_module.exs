defmodule Turnos.Repo.Migrations.UpdateOperator4Module do
  use Ecto.Migration

  def change do
    execute(
      "UPDATE operators SET module = '2' WHERE id = 4",
      "UPDATE operators SET module = NULL WHERE id = 4"
    )
  end
end
