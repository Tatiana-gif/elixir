defmodule TurnosWeb.OperatorPanelLive.Index do
  use TurnosWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    operator_id = session["operator_id"]
    operator_name = session["operator_name"] || "Operador"

    # Count by status
    pending_count = if operator_id, do: Turnos.Queueing.count_pending_for_operator(operator_id), else: 0
    attending_count = if operator_id, do: Turnos.Queueing.count_attending_for_operator(operator_id), else: 0
    total_assigned = if operator_id, do: Turnos.Queueing.count_all_for_operator(operator_id), else: 0
    completed_today = if operator_id, do: Turnos.Queueing.count_completed_today_for_operator(operator_id), else: 0

    if operator_id do
      Phoenix.PubSub.subscribe(Turnos.PubSub, "queues")
    end

    socket =
      socket
      |> assign(operator_id: operator_id, operator_name: operator_name)
      |> assign(active_section: "dashboard")
      |> assign(pending_count: pending_count, attending_count: attending_count, total_assigned: total_assigned, completed_today: completed_today)

    {:ok, socket}
  end

  @impl true
  def handle_info({:queue_updated, _queue}, socket) do
    operator_id = socket.assigns[:operator_id]

    pending_count = if operator_id, do: Turnos.Queueing.count_pending_for_operator(operator_id), else: 0
    attending_count = if operator_id, do: Turnos.Queueing.count_attending_for_operator(operator_id), else: 0
    total_assigned = if operator_id, do: Turnos.Queueing.count_all_for_operator(operator_id), else: 0
    completed_today = if operator_id, do: Turnos.Queueing.count_completed_today_for_operator(operator_id), else: 0

    {:noreply, assign(socket, pending_count: pending_count, attending_count: attending_count, total_assigned: total_assigned, completed_today: completed_today)}
  end

  @impl true
  def handle_event("complete_attendance", %{"queue_id" => queue_id}, socket) do
    case Turnos.Queueing.mark_completed(queue_id) do
      {:ok, _queue} ->
        {:noreply, put_flash(socket, :info, "Turno completado correctamente")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error al completar el turno")}
    end
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "operator"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; position: relative;">
        <!-- Header con información del operador -->
        <div class="bg-white border-b border-gray-200 shadow-sm relative z-10">
          <div class="container mx-auto px-6 py-4">
            <div class="flex justify-between items-center">
              <div>
                <h1 class="text-3xl font-bold text-gray-900">Panel del Operador</h1>

                <p class="text-gray-600 mt-1">
                  Bienvenido de vuelta <span class="font-semibold">{@operator_name}</span>
                </p>
              </div>
            </div>
          </div>
        </div>
        <!-- Main Content -->
        <div class="container mx-auto px-3 py-6 relative z-10">
          <!-- Stats Cards -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <div class="bg-blue-500/50 transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 rounded-lg shadow p-6 border-l-6 border-blue-500">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-black-600 text-sm font-medium">Turnos Pendientes</p>
                  <p class="text-4xl font-bold text-black-900 mt-2">{@pending_count}</p>
                </div>

                <div class="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                  <svg class="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>
              </div>
            </div>


            <div class="bg-purple-500/50 transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 rounded-lg shadow p-6 border-l-4 border-purple-500">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-black-600 text-sm font-medium">Completados Hoy</p>

                  <p class="text-4xl font-bold text-black-900 mt-2">{@completed_today}</p>
                </div>

                <div class="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                  <svg class="w-6 h-6 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" />
                    <path
                      fill-rule="evenodd"
                      d="M4 5a2 2 0 012-2 1 1 0 000-2 4 4 0 00-4 4v10a4 4 0 004 4h12a4 4 0 004-4V5a4 4 0 00-4-4 1 1 0 000 2 2 2 0 012 2v10a2 2 0 01-2 2H6a2 2 0 01-2-2V5z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </div>
              </div>
            </div>

            <div class="bg-orange-500/50 transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 rounded-lg shadow p-6 border-l-4 border-orange-500">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-black-600 text-sm font-medium">Total Asignados</p>

                  <p class="text-4xl font-bold text-black-900 mt-2">{@total_assigned}</p>
                </div>

                <div class="w-12 h-12 bg-orange-100 rounded-full flex items-center justify-center">
                  <svg class="w-6 h-6 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" />
                  </svg>
                </div>
              </div>
            </div>
          </div>

          <!-- Acciones Rapidas -->
          <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-xl font-bold text-gray-900 mb-4">Conocer estado de turnos</h2>

            <div class="space-y-2">
              <a
                href={~p"/my-queues"}
                class="block w-full bg-blue-500 hover:bg-blue-600 text-white px-4 py-3 rounded-lg font-medium text-center transition"
              >
                Ver Mis Turnos
              </a>


            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
