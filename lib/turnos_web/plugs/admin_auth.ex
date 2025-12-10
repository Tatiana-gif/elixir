defmodule TurnosWeb.Plugs.AdminAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    secret = Application.get_env(:turnos, :admin_secret)

    if get_session(conn, :admin) == secret do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end
end
