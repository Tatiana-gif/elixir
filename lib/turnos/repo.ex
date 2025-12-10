defmodule Turnos.Repo do
  use Ecto.Repo,
    otp_app: :turnos,
    adapter: Ecto.Adapters.Postgres
end
