defmodule TurnosWeb.OperatorSessionController do
  use TurnosWeb, :controller

  def create(conn, %{"operator" => operator_params}) do
    case authenticate_operator(operator_params) do
      {:ok, operator} ->
        # Mark operator as online
        Turnos.Operators.mark_online(operator)

        conn
        |> put_session(:operator_id, operator.id)
        |> put_session(:operator_email, operator.email)
        |> put_session(:operator_name, operator.name)
        |> redirect(to: ~p"/panel")

      {:error, :operator_inactive} ->
        conn
        |> put_flash(:error, "Tu cuenta no está activada. Contacta al administrador.")
        |> redirect(to: ~p"/operator/login")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Email o contraseña inválidos")
        |> redirect(to: ~p"/operator/login")
    end
  end

  def delete(conn, _params) do
    # Mark operator as offline
    operator_id = get_session(conn, :operator_id)

    if operator_id do
      operator = Turnos.Operators.get_operator!(operator_id)
      Turnos.Operators.mark_offline(operator)
    end

    conn
    |> clear_session()
    |> redirect(to: ~p"/")
  end

  defp authenticate_operator(%{"email" => email, "password" => password}) do
    Turnos.Operators.get_operator_by_email_and_password(email, password)
  end

  defp authenticate_operator(_), do: {:error, :missing_params}
end
