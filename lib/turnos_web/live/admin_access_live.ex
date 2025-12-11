defmodule TurnosWeb.AdminAccessLive do
  use TurnosWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, error: nil)}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :current_scope, %{})

    ~H"""
    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">

      <div class="min-h-screen flex items-center justify-center ">
        <div class="bg-white rounded-lg shadow-xl p-8 w-full max-w-md">
          <h1 class="text-2xl font-bold text-center mb-2 text-gray-800">Acceso Administrativo</h1>

          <p class="text-center text-gray-500 mb-6">Ingresa la clave de administración</p>

          <form action={~p"/admin/session"} method="post" class="space-y-4">
            <input type="hidden" name="_csrf_token" value={Phoenix.Controller.get_csrf_token()} />
            <div>
              <label for="secret" class="block text-sm font-medium text-gray-700">
                Clave de Admin
              </label>
              <input
                type="password"
                name="admin[secret]"
                id="secret"
                required
                class="mt-1 w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              class="mt-6 w-full bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg transition duration-200"
            >
              Acceder
            </button>
          </form>

          <div class="mt-6 text-center text-xs text-gray-400">
            <p>Ruta protegida de administración</p>
          </div>
        </div>
      </div>
      </div>
    """
  end
end
