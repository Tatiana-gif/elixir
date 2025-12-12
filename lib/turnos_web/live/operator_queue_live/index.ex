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

    # Filter pending and attending queues
    pending_queues = Enum.filter(queues, &(&1.status == "pending"))
    attending_queues = Enum.filter(queues, &(&1.status in ["waiting", "attending"]))

    {:ok,
     assign(socket, queues: queues, pending_queues: pending_queues, attending_queues: attending_queues, operator_id: operator_id)}
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
        attending_queues = Enum.filter(queues, &(&1.status in ["waiting", "attending"]))

        {:noreply,
         socket
         |> assign(queues: queues, pending_queues: pending_queues, attending_queues: attending_queues)
         |> put_flash(:info, "Turno llamado. Ahora visible en pantalla pública.")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al llamar el turno")}
    end
  end

  @impl true
  def handle_event("complete_queue", %{"queue_id" => queue_id}, socket) do
    case Turnos.Queueing.mark_completed(queue_id) do
      {:ok, _queue} ->
        # Refresh queues list
        operator_id = socket.assigns[:operator_id]

        queues =
          if operator_id, do: Turnos.Queueing.list_queues_for_operator(operator_id), else: []

        pending_queues = Enum.filter(queues, &(&1.status == "pending"))
        attending_queues = Enum.filter(queues, &(&1.status in ["waiting", "attending"]))

        {:noreply,
         socket
         |> assign(queues: queues, pending_queues: pending_queues, attending_queues: attending_queues)
         |> put_flash(:info, "Turno completado correctamente.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error al completar el turno")}
    end
  end

  @impl true
  def handle_info({:queue_updated, _queue}, socket) do
    operator_id = socket.assigns[:operator_id]
    queues = if operator_id, do: Turnos.Queueing.list_queues_for_operator(operator_id), else: []
    pending_queues = Enum.filter(queues, &(&1.status == "pending"))
    attending_queues = Enum.filter(queues, &(&1.status in ["waiting", "attending"]))
    {:noreply, assign(socket, queues: queues, pending_queues: pending_queues, attending_queues: attending_queues)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "operator"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="container mx-auto p-4">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Turnos Pendientes -->
          <div>
            <h2 class="text-2xl font-bold mb-4 text-orange-600">Turnos Pendientes</h2>

            <div class="mt-4">
              <%= if Enum.empty?(@pending_queues) do %>
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 text-blue-700">
                  <p class="font-semibold">No tienes turnos pendientes</p>
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

          <!-- Turnos en Atención -->
          <div>
            <h2 class="text-2xl font-bold mb-4 text-blue-600">Turnos en Atención</h2>

            <div class="mt-4">
              <%= if Enum.empty?(@attending_queues) do %>
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 text-blue-700">
                  <p class="font-semibold">No tienes turnos en atención</p>
                </div>
              <% else %>
                <div class="space-y-3">
                  <%= for q <- @attending_queues do %>
                    <div class="p-4 border-l-4 border-blue-500 rounded bg-white shadow-sm flex justify-between items-center">
                      <div>
                        <p class="text-2xl font-bold text-gray-900">Turno {q.number}</p>

                        <p class="text-sm text-gray-500">Módulo: {q.module}</p>

                        <span class={[
                          "inline-block mt-2 px-3 py-1 text-xs font-semibold rounded-full",
                          if(q.status == "waiting", do: "bg-blue-100 text-blue-700", else: "bg-green-100 text-green-700")
                        ]}>
                          {if q.status == "waiting", do: "Llamado", else: "En Atención"}
                        </span>
                      </div>

                      <button
                        phx-click="complete_queue"
                        phx-value-queue_id={q.id}
                        class="bg-red-500 hover:bg-red-600 text-white font-semibold px-6 py-3 rounded-lg transition duration-200 text-center"
                      >
                        Completar
                      </button>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
