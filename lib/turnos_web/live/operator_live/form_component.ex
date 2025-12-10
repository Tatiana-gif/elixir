defmodule TurnosWeb.OperatorLive.FormComponent do
  use TurnosWeb, :live_component

  alias Turnos.Operators

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("submit", %{"operator" => operator_params}, socket) do
    case socket.assigns[:operator] do
      nil ->
        # Creating new operator
        create_operator(operator_params, socket)

      operator ->
        # Updating existing operator
        update_operator(operator, operator_params, socket)
    end
  end

  defp create_operator(operator_params, socket) do
    case Operators.create_operator(operator_params) do
      {:ok, _operator} ->
        send(self(), :operator_created)
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp update_operator(operator, operator_params, socket) do
    case Operators.update_operator(operator, operator_params) do
      {:ok, _operator} ->
        send(self(), :operator_created)
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :operator, assigns[:operator])

    ~H"""
    <div>
    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">

      <form phx-submit="submit" phx-target={@myself} class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              type="email"
              name="operator[email]"
              required
              value={@operator && @operator.email}
              disabled={@operator != nil}
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
              placeholder="Correo"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Nombre Completo</label>
            <input
              type="text"
              name="operator[name]"
              required
              value={@operator && @operator.name}
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Nombre"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Módulo/Sucursal</label>
            <input
              type="text"
              name="operator[module]"
              value={@operator && @operator.module}
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Módulo"
            />
          </div>


          <%= if !@operator do %>
            <div class="col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Contraseña Temporal</label>
              <input
                type="text"
                name="operator[password]"
                required
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="Contraseña"
                minlength="6"
              />
              <p class="text-xs text-gray-500 mt-1">
                El operador podrá cambiarla en su primer acceso
              </p>
            </div>
          <% end %>
        </div>

        <div class="flex gap-2 pt-4">
          <button
            type="submit"
            class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition"
          >
            {if @operator, do: "Guardar Cambios", else: "Crear Operador"}
          </button>
          <button
            type="button"
            phx-click="hide-form"
            class="bg-gray-300 hover:bg-gray-400 text-gray-900 px-6 py-2 rounded-lg font-medium transition"
          >
            Cancelar
          </button>
        </div>
      </form>
    </div>
      </div>
    """
  end
end
