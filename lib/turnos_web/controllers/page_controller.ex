defmodule TurnosWeb.PageController do
  use TurnosWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
