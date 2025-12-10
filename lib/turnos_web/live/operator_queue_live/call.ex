defmodule TurnosWeb.OperatorQueueLive.Call do
  use TurnosWeb, :live_view

  @impl true
  def mount(%{"id" => id}, session, socket) do
    operator_id = Map.get(session, "operator_id") || Map.get(session, :operator_id)

    {:ok,
     assign(socket, queue_id: id, queue: nil, operator_id: operator_id, last_called_queue: nil)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "operator"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="container mx-auto p-4">
        <h1 class="text-3xl font-bold mb-4">Llamar Turno</h1>
        
        <button phx-click="call-next" class="bg-blue-500 text-white px-4 py-2 rounded">
          Llamar siguiente
        </button>
        <%= if @last_called_queue do %>
          <div class="mt-4 p-4 border rounded bg-yellow-50">
            <p class="text-lg font-bold">Turno llamado: {@last_called_queue.number}</p>
            
            <p class="text-sm text-gray-700 mb-2">ID: {@last_called_queue.id}</p>
            
            <div class="flex gap-2">
              <button
                phx-click="confirm-attend"
                phx-value-id={@last_called_queue.id}
                class="bg-green-500 text-white px-3 py-1 rounded text-sm"
              >
                Confirmar Atención
              </button>
              <button
                phx-click="dismiss-called"
                class="bg-gray-200 text-gray-800 px-3 py-1 rounded text-sm"
              >
                Descartar
              </button>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("call-next", _params, socket) do
    operator_id = socket.assigns[:operator_id]

    case Turnos.Queueing.call_next(operator_id) do
      {:ok, queue} ->
        socket = socket |> put_flash(:info, "Turno llamado") |> assign(:last_called_queue, queue)
        {:noreply, socket}

      {:error, :no_pending} ->
        {:noreply, put_flash(socket, :warning, "No hay turnos pendientes")}

      _ ->
        {:noreply, put_flash(socket, :error, "Error al llamar turno")}
    end
  end

  @impl true
  def handle_event("confirm-attend", %{"id" => id}, socket) do
    case Turnos.Queueing.mark_attending(id) do
      {:ok, _queue} ->
        {:noreply,
         socket |> put_flash(:info, "Turno en atención") |> assign(:last_called_queue, nil)}

      _ ->
        {:noreply, socket |> put_flash(:error, "No se pudo confirmar atención")}
    end
  end

  @impl true
  def handle_event("dismiss-called", _params, socket) do
    {:noreply, assign(socket, :last_called_queue, nil)}
  end
end
