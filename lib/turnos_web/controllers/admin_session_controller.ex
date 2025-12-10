defmodule TurnosWeb.AdminSessionController do
  use TurnosWeb, :controller

  def create(conn, %{"admin" => admin_params}) do
    config_secret = Application.get_env(:turnos, :admin_secret)

    case admin_params["secret"] do
      ^config_secret ->
        conn
        |> put_session(:admin, config_secret)
        |> put_flash(:info, "Acceso de administrador concedido")
        |> redirect(to: ~p"/admin/operators")

      _ ->
        conn
        |> put_flash(:error, "Contraseña de administrador inválida")
        |> redirect(to: ~p"/gestion/admin/acceso")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "Sesión cerrada")
    |> redirect(to: ~p"/")
  end
end
