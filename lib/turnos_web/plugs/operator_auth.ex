defmodule TurnosWeb.Plugs.OperatorAuth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :operator_id) do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end
end
