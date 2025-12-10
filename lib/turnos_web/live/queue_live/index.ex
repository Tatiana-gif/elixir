defmodule TurnosWeb.QueueLive.Index do
  use TurnosWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, queues: [])}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "admin"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="container mx-auto p-4">
        <h1 class="text-2xl font-bold mb-4">Gestión de Colas</h1>
        
        <p class="text-gray-500">Administra todas las colas del sistema</p>
      </div>
    </Layouts.app>
    """
  end
end
