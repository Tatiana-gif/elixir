# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Turnos.Repo.insert!(%Turnos.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Turnos.Repo
alias Turnos.Operators.Operator

# Crear un operador admin por defecto para testing
admin_email = "admin@turnos.local"
admin_password = "admin123"

case Repo.get_by(Operator, email: admin_email) do
  nil ->
    admin_changeset =
      Operator.changeset(%Operator{}, %{
        "email" => admin_email,
        "password" => admin_password,
        "name" => "Administrador",
        "status" => "active"
      })

    Repo.insert!(admin_changeset)
    IO.puts("✓ Operador admin creado: #{admin_email} / #{admin_password}")

  _existing ->
    IO.puts("✓ Operador admin ya existe")
end

# Actualizar el operador Leo Orozco (id=4) con módulo "2"
case Repo.get(Operator, 4) do
  nil ->
    IO.puts("⚠ Operador id=4 no encontrado")

  leo ->
    leo
    |> Ecto.Changeset.change(%{module: "2"})
    |> Repo.update!()

    IO.puts("✓ Operador Leo Orozco actualizado con módulo '2'")
end

# Actualizar el operador Pablo (id=2) con módulo diferente para evitar conflicto
case Repo.get(Operator, 2) do
  nil ->
    IO.puts("⚠ Operador id=2 no encontrado")

  pablo ->
    pablo
    |> Ecto.Changeset.change(%{module: "3"})
    |> Repo.update!()

    IO.puts("✓ Operador Pablo actualizado con módulo '3'")
end

# Verificación: Mostrar todos los operadores con sus módulos
IO.puts("\n=== Operadores en la base de datos ===")

Repo.all(Operator)
|> Enum.sort_by(& &1.id)
|> Enum.each(fn op ->
  IO.puts("ID=#{op.id} | #{op.name} | Módulo: #{op.module || "nil"}")
end)

# Verificación: Intentar obtener operador por módulo
IO.puts("\n=== Buscando operador con módulo '2' ===")

case Turnos.Operators.get_operator_by_module("2") do
  nil ->
    IO.puts("❌ No encontrado")

  op ->
    IO.puts("✓ Encontrado: ID=#{op.id} | #{op.name} | Módulo=#{op.module}")
end
