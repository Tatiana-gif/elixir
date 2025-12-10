defmodule TurnosWeb.Router do
  use TurnosWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TurnosWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # 🔐 Pipeline para proteger la ruta de admin
  pipeline :admin_auth do
    plug TurnosWeb.Plugs.AdminAuth
  end

  # 🔐 Pipeline para proteger rutas de operador
  pipeline :require_authenticated_operator do
    plug TurnosWeb.Plugs.OperatorAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # RUTAS PÚBLICAS - Visualización de turnos en pantalla
  scope "/", TurnosWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/display", QueueDisplayLive.Index
    live "/turnos", QueueDisplayLive.Index
    live "/register", RegisterQueueLive

    # Login de operadores
    live "/operator/login", OperatorLoginLive
    post "/operator/session", OperatorSessionController, :create
    post "/operator/logout", OperatorSessionController, :delete

    # Ruta oculta para acceso de administrador
    live "/gestion/admin/acceso", AdminAccessLive
    post "/admin/session", AdminSessionController, :create
    post "/admin/logout", AdminSessionController, :delete
  end

  # ZONA DEL ADMINISTRADOR (protegida)

  scope "/admin", TurnosWeb do
    pipe_through [:browser, :admin_auth]

    # Gestión de operadores - SOLO CRUD
    live "/operators", OperatorLive.Index
  end

  #  ZONA DEL OPERADOR (requiere login)
  scope "/", TurnosWeb do
    pipe_through [:browser, :require_authenticated_operator]

    # Panel del operador
    live "/panel", OperatorPanelLive.Index

    # Gestión de sus turnos
    live "/my-queues", OperatorQueueLive.Index
    live "/my-queues/:id/call", OperatorQueueLive.Call
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:turnos, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TurnosWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
