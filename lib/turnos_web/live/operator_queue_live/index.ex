defmodule TurnosWeb.OperatorQueueLive.Index do
  use TurnosWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    operator_id = session["operator_id"] || session[:operator_id]

    if connected?(socket), do: Phoenix.PubSub.subscribe(Turnos.PubSub, "queues")

    queues =
      if operator_id do
        Turnos.Queueing.list_queues_for_operator(operator_id)
      else
        []
      end

    # Filter only pending queues
    pending_queues = Enum.filter(queues, &(&1.status == "pending"))

    {:ok,
     assign(socket, queues: queues, pending_queues: pending_queues, operator_id: operator_id)}
  end

  @impl true
  def handle_event("call_next", %{"queue_id" => queue_id}, socket) do
    # Change queue status from pending to waiting (now visible in public display)
    queue = Turnos.Queueing.get_queue!(queue_id)

    case Turnos.Queueing.update_queue(queue, %{"status" => "waiting"}) do
      {:ok, _queue} ->
        # Broadcast update
        Phoenix.PubSub.broadcast(Turnos.PubSub, "queues", {:queue_updated, queue})

        # Refresh queues list
        operator_id = socket.assigns[:operator_id]

        queues =
          if operator_id, do: Turnos.Queueing.list_queues_for_operator(operator_id), else: []

        pending_queues = Enum.filter(queues, &(&1.status == "pending"))

        {:noreply,
         socket
         |> assign(queues: queues, pending_queues: pending_queues)
         |> put_flash(:info, "Turno llamado. Ahora visible en pantalla pública.")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al llamar el turno")}
    end
  end

  @impl true
  def handle_info({:queue_updated, _queue}, socket) do
    operator_id = socket.assigns[:operator_id]
    queues = if operator_id, do: Turnos.Queueing.list_queues_for_operator(operator_id), else: []
    pending_queues = Enum.filter(queues, &(&1.status == "pending"))
    {:noreply, assign(socket, queues: queues, pending_queues: pending_queues)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "operator"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="container mx-auto p-4">
        <h1 class="text-2xl font-bold mb-4">Mis Turnos Pendientes</h1>
        
        <p class="text-gray-500">Turnos asignados esperando tu acción</p>
        
        <div class="mt-4">
          <%= if Enum.empty?(@pending_queues) do %>
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 text-blue-700">
              <p class="font-semibold">No tienes turnos pendientes</p>
              
              <p class="text-sm">Los turnos aparecerán aquí cuando se registren para tu módulo</p>
            </div>
          <% else %>
            <div class="space-y-3">
              <%= for q <- @pending_queues do %>
                <div class="p-4 border-l-4 border-orange-500 rounded bg-white shadow-sm flex justify-between items-center">
                  <div>
                    <p class="text-2xl font-bold text-gray-900">Turno {q.number}</p>
                    
                    <p class="text-sm text-gray-500">Módulo: {q.module}</p>
                    
                    <span class="inline-block mt-2 px-3 py-1 bg-orange-100 text-orange-700 text-xs font-semibold rounded-full">
                      Pendiente
                    </span>
                  </div>
                  
                  <button
                    phx-click="call_next"
                    phx-value-queue_id={q.id}
                    class="bg-green-500 hover:bg-green-600 text-white font-semibold px-6 py-3 rounded-lg transition duration-200 text-center"
                  >
                    Próximo Turno
                  </button>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
