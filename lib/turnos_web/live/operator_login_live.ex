defmodule TurnosWeb.OperatorLoginLive do
  use TurnosWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, error: nil)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{})

    ~H"""
    <img src={~p"/images/tcs-logo-left.svg"} width="120" />

    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">

      <div class="min-h-screen flex items-center justify-center">
        <div class="bg-white border border-black rounded-lg shadow-xl p-8 w-full max-w-md">
          <h1 class="text-3xl font-bold text-center mb-2 text-gray-800">Operadores</h1>


          <%= if @error do %>
            <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4">
              {@error}
            </div>
          <% end %>

          <form action={~p"/operator/session"} method="post" class="space-y-4">
            <input type="hidden" name="_csrf_token" value={Phoenix.Controller.get_csrf_token()} />
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
              <input
                type="email"
                name="operator[email]"
                id="email"
                required
                class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="tu@email.com"
              />
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-gray-700">Contraseña</label>
              <input
                type="password"
                name="operator[password]"
                id="password"
                required
                class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
            >
              Ingresar
            </button>
          </form>

          <div class="mt-6 text-center text-sm text-gray-500">
            <p>¿No tienes cuenta? Contacta a administración</p>
          </div>
        </div>
      </div>
      </div>
    """
  end
end
