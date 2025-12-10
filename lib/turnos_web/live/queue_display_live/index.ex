defmodule TurnosWeb.QueueDisplayLive.Index do
  use TurnosWeb, :live_view
  alias Turnos.Queueing

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(2_000, :refresh_queues)

    queues = Queueing.list_queues()

    # Filter only queues with "waiting" status (confirmed by operator)
    waiting_queues = Enum.filter(queues, &(&1.status == "waiting"))

    {:ok, assign(socket, queues: waiting_queues, turnos: waiting_queues)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{})

    ~H"""

    <img src={~p"/images/tcs-logo-left.svg"} width="80" />
    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">

    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-bold mb-4 text-center">TURNOS EN PANTALLA</h1>
      <!-- Sección tabla -->
      <div class="bg-white rounded-lg shadow mb-8">
        <div class="bg-green-50 border-b border-green-200 px-6 py-4">
          <h2 class="text-lg font-bold text-green-900">Registro de turnos</h2>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full">
            <thead class="bg-gray-100">
              <tr>
                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Modulo</th>

                <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Turno</th>
              </tr>
            </thead>

            <tbody>
              <%= for turno <- @turnos do %>
                <tr>
                  <td class="px-6 py-4 text-sm text-gray-800">{turno.module}</td>

                  <td class="px-6 py-4 text-sm text-gray-800">{turno.number}</td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
      <!-- Sección tarjetas -->
      <div class="grid grid-cols-2 gap-4">
        <%= for queue <- @queues do %>
          <div class={[
            "border p-4 rounded",
            if(queue.status == "calling", do: "bg-yellow-50", else: "bg-white")
          ]}>
            <p class="text-sm text-gray-500">{queue_status_label(queue.status)}</p>

            <p class="text-4xl font-bold text-black">{queue.number}</p>
          </div>
        <% end %>
      </div>
    </div>
    </div>
    """
  end

  @impl true
  def handle_info(:refresh_queues, socket) do
    queues = Queueing.list_queues()
    # Filter only queues with "waiting" status
    waiting_queues = Enum.filter(queues, &(&1.status == "waiting"))
    {:noreply, assign(socket, queues: waiting_queues, turnos: waiting_queues)}
  end

  defp queue_status_label("calling"), do: "Llamando"
  defp queue_status_label("attending"), do: "En atención"
  defp queue_status_label(_), do: "Pendiente"
end
