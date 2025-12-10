defmodule TurnosWeb.QueueLive.Show do
  use TurnosWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign(socket, queue_id: id, queue: nil)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "admin"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="container mx-auto p-4">
        <h1 class="text-2xl font-bold mb-4">Detalle de Cola</h1>
      </div>
    </Layouts.app>
    """
  end
end
