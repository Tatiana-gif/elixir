defmodule TurnosWeb.OperatorLive.Index do
  use TurnosWeb, :live_view

  alias Turnos.Operators

  @impl true
  def mount(_params, _session, socket) do
    operators = Operators.list_operators()

    # Schedule periodic refresh every 5 seconds
    if connected?(socket) do
      :timer.send_interval(5000, self(), :refresh)
    end

    {:ok, assign(socket, operators: operators, show_form: false, editing_operator: nil)}
  end

  @impl true
  def handle_info(:refresh, socket) do
    operators = Operators.list_operators()
    {:noreply, assign(socket, operators: operators)}
  end

  @impl true
  def handle_info(:operator_created, socket) do
    operators = Operators.list_operators()
    {:noreply, assign(socket, operators: operators, show_form: false)}
  end

  @impl true
  def handle_event("toggle-status", %{"id" => id}, socket) do
    operator = Operators.get_operator!(id)

    new_status = if operator.status == "active", do: "inactive", else: "active"

    {:ok, _updated} = Operators.update_operator(operator, %{"status" => new_status})

    operators = Operators.list_operators()
    {:noreply, assign(socket, operators: operators)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    operator = Operators.get_operator!(id)
    {:ok, _} = Operators.delete_operator(operator)

    operators = Operators.list_operators()
    {:noreply, assign(socket, operators: operators)}
  end

  def handle_event("show-form", _value, socket) do
    {:noreply, assign(socket, show_form: true, editing_operator: nil)}
  end

  def handle_event("hide-form", _value, socket) do
    {:noreply, assign(socket, show_form: false, editing_operator: nil)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    operator = Operators.get_operator!(id)
    {:noreply, assign(socket, editing_operator: operator, show_form: true)}
  end

  def handle_event("cancel-edit", _value, socket) do
    {:noreply, assign(socket, show_form: false, editing_operator: nil)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{page: "admin"})

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">

      <div class="container mx-auto px-6 py-8">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h1 class="text-3xl font-bold text-white-900">Gestión de Operadores</h1>

          </div>

          <button
            phx-click="show-form"
            class="bg-blue-600 hover:bg-white-700 text-white px-6 py-2 rounded-lg font-medium transition"
          >
            + Nuevo Operador
          </button>
          <div class="flex items-center gap-3"></div>
        </div>

   

        <%= if @show_form do %>
          <div class="bg-white-700 rounded-lg p-6 mb-6">
            <div class="flex justify-between items-center mb-4 bg-black-50 ">
              <h2 class="text-xl bg-white-50">
                {if @editing_operator, do: "Editar Operador", else: "Crear Nuevo Operador"}
              </h2>

              <button
                phx-click="hide-form"
                class="text-black-500 hover:text-black-700 text-2xl"
              >
                ×
              </button>
            </div>


            <.live_component
              module={TurnosWeb.OperatorLive.FormComponent}
              id={if @editing_operator, do: @editing_operator.id, else: "new-operator"}
              operator={@editing_operator}
            />
          </div>
        <% end %>
        <!-- Operadores Activos -->
        <div class="bg-white rounded-lg shadow mb-8">
          <div class="bg-green-50 border-b border-green-200 px-6 py-4">
            <h2 class="text-lg font-bold text-green-900">
               Operadores Activos ({Enum.count(@operators, &(&1.status == "active"))})
            </h2>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full">
              <thead class="bg-gray-100">
                <tr>
                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Email</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Nombre</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Módulo</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Estado</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                    Última Conexión
                  </th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Creado</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Acciones</th>
                </tr>
              </thead>

              <tbody class="divide-y divide-gray-200">
                <%= for operator <- Enum.filter(@operators, &(&1.status == "active")) do %>
                  <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 text-sm text-gray-900">{operator.email}</td>

                    <td class="px-6 py-4 text-sm text-gray-600">{operator.name || "-"}</td>

                    <td class="px-6 py-4 text-sm text-gray-600">{operator.module}</td>

                    <td class="px-6 py-4 text-sm">
                      <%= if operator.online_status == "online" do %>
                        <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">
                          <span class="w-2 h-2 bg-green-600 rounded-full animate-pulse"></span>
                          Conectado
                        </span>
                      <% else %>
                        <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800">
                          <span class="w-2 h-2 bg-gray-400 rounded-full"></span> Desconectado
                        </span>
                      <% end %>
                    </td>

                    <td class="px-6 py-4 text-sm text-gray-600">
                      <%= if operator.last_seen_at do %>
                        {Calendar.strftime(operator.last_seen_at, "%d/%m/%Y %H:%M:%S")}
                      <% else %>
                        -
                      <% end %>
                    </td>

                    <td class="px-6 py-4 text-sm text-gray-600">
                      {Calendar.strftime(operator.inserted_at, "%d/%m/%Y")}
                    </td>

                    <td class="px-6 py-4 text-sm space-x-2">
                      <button
                        phx-click="edit"
                        phx-value-id={operator.id}
                        class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-xs"
                      >
                        Editar
                      </button>
                      <button
                        phx-click="toggle-status"
                        phx-value-id={operator.id}
                        class="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-1 rounded text-xs"
                      >
                        Desactivar
                      </button>
                      <button
                        phx-click="delete"
                        phx-value-id={operator.id}
                        data-confirm="¿Eliminar operador?"
                        class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs"
                      >
                        Eliminar
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
        <!-- Operadores Inactivos -->
        <div class="bg-white rounded-lg shadow">
          <div class="bg-gray-50 border-b border-gray-200 px-6 py-4">
            <h2 class="text-lg font-bold text-gray-900">
              Operadores Inactivos ({Enum.count(@operators, &(&1.status != "active"))})
            </h2>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full">
              <thead class="bg-gray-100">
                <tr>
                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Email</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Nombre</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Módulo</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Estado</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                    Última Conexión
                  </th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Creado</th>

                  <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Acciones</th>
                </tr>
              </thead>

              <tbody class="divide-y divide-gray-200">
                <%= for operator <- Enum.filter(@operators, &(&1.status != "active")) do %>
                  <tr class="hover:bg-gray-50 opacity-60">
                    <td class="px-6 py-4 text-sm text-gray-900">{operator.email}</td>

                    <td class="px-6 py-4 text-sm text-gray-600">{operator.name || "-"}</td>

                    <td class="px-6 py-4 text-sm text-gray-600">{operator.module}</td>

                    <td class="px-6 py-4 text-sm">
                      <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800">
                        <span class="w-2 h-2 bg-gray-400 rounded-full"></span> Desconectado
                      </span>
                    </td>

                    <td class="px-6 py-4 text-sm text-gray-600">
                      <%= if operator.last_seen_at do %>
                        {Calendar.strftime(operator.last_seen_at, "%d/%m/%Y %H:%M:%S")}
                      <% else %>
                        -
                      <% end %>
                    </td>

                    <td class="px-6 py-4 text-sm text-gray-600">
                      {Calendar.strftime(operator.inserted_at, "%d/%m/%Y")}
                    </td>

                    <td class="px-6 py-4 text-sm space-x-2">
                      <button
                        phx-click="edit"
                        phx-value-id={operator.id}
                        class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-xs"
                      >
                        Editar
                      </button>
                      <button
                        phx-click="toggle-status"
                        phx-value-id={operator.id}
                        class="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded text-xs"
                      >
                        Activar
                      </button>
                      <button
                        phx-click="delete"
                        phx-value-id={operator.id}
                        data-confirm="¿Eliminar operador?"
                        class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-xs"
                      >
                        Eliminar
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      </div>
    </Layouts.app>
    """
  end
end
