defmodule TurnosWeb.RegisterQueueLive do
  use TurnosWeb, :live_view
  alias Turnos.Queueing
  alias Turnos.Queueing.Queue
  alias Turnos.Operators

  @impl true
  def mount(_params, _session, socket) do
    changeset = Queueing.change_queue(%Queue{})
    {:ok, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"queue" => params}, socket) do
    changeset =
      %Queue{}
      |> Queueing.change_queue(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"queue" => params}, socket) do
    # Find operator by module
    case find_operator_by_module(params["module"]) do
      nil ->
        changeset =
          %Queue{}
          |> Queueing.change_queue(params)
          |> Ecto.Changeset.add_error(:module, "No hay un operador asignado a este módulo")

        {:noreply, assign(socket, form: to_form(changeset))}

      operator ->
        # Create queue with pending status and assign to operator
        queue_params =
          params
          |> Map.put("operator_id", operator.id)
          |> Map.put("status", "pending")

        case Queueing.create_queue(queue_params) do
          {:ok, queue} ->
            # Broadcast to notify operator's view
            Phoenix.PubSub.broadcast(Turnos.PubSub, "queues", {:queue_updated, queue})

            {:noreply,
             socket
             |> put_flash(:info, "Turno #{params["number"]} asignado a #{operator.name}")
             |> push_navigate(to: "/display")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end
    end
  end

  defp find_operator_by_module(module) do
    if module && module != "" do
      Operators.get_operator_by_module(module)
    else
      nil
    end
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{})

    ~H"""
    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">
       <br>
       <br>
       <br>

      <div class="container mx-auto p-6 max-w-md">
        <div class="bg-white rounded-lg shadow-lg p-8">

          <h1 class="text-3xl font-bold mb-2 text-gray-900">Registrar Turno</h1>

          <p class="text-gray-600 mb-6">Asigna un turno al módulo correspondiente</p>

          <.form
            for={@form}
            id="queue-form"
            phx-change="validate"
            phx-submit="save"
          >
            <!-- Módulo -->
            <div class="mb-5">
              <label class="block font-medium text-gray-700 mb-2">Módulo</label>
              <.input
                field={@form[:module]}
                type="text"

                class="border rounded w-full p-3"
              />
            </div>
            <!-- Número del turno -->
            <div class="mb-6">
              <label class="block font-medium text-gray-700 mb-2">Número del Turno</label>
              <.input
                field={@form[:number]}
                type="number"
                class="border rounded w-full p-3"
              />
            </div>

            <button
              type="submit"
              class="w-full bg-green-600 text-black-200 font-semibold px-4 py-3 rounded-lg hover:bg-green-700 transition duration-200"
            >
              Asignar Turno
            </button>
          </.form>
        </div>
      </div>
      </div>
    """
  end
end
