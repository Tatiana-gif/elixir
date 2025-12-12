defmodule TurnosWeb.LandingLive do
  use TurnosWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <img src={~p"/images/tcs-logo-left.svg"} width="120" />

    <div style="background-image: url('/images/example.png'); background-attachment: fixed; background-position: center; background-repeat: no-repeat; background-size: cover; min-height: 100vh; ">

    <div class=" via-blue-500 to-purple-600 flex items-center justify-center p-4">
      <div class="max-w-2xl w-full">
        <!-- Logo/Título -->
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold text-white mb-2">SISTEMA DE TURNOS</h1>
        </div>

        <!-- Card de opciones -->
        <div >
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Botón Admin -->
            <.link
              navigate={~p"/gestion/admin/acceso"}
              class="group flex flex-col items-center justify-center p-8 rounded-xl bg-green-500/50  transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 transition duration-300 border-2 border-black-300 hover:border-green-500  "
            >
              <div class="text-5xl mb-4"></div>
              <h2 class="text-2xl font-bold text-black-900 mb-2">Administrador</h2>
              <div class="mt-4 text-black-600 font-semibold group-hover:text-black-700">
                Ingresar
              </div>
            </.link>

            <!-- Botón Operador -->
            <.link
              navigate={~p"/operator/login"}
              class="group flex flex-col items-center justify-center p-8 rounded-xl bg-yellow-500/50  transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 transition duration-300 border-2 border-black-300 hover:border-yellow-500"

            >
              <div class="text-5xl mb-4"></div>
              <h2 class="text-2xl font-bold text-black-900 mb-2">Operador</h2>
              <div class="mt-4 text-black-600 font-semibold">
                Ingresar
              </div>
            </.link>

            <!-- Botón Registrar Turno -->
            <.link
              navigate={~p"/register"}
              class="group flex flex-col items-center justify-center p-8 rounded-xl bg-blue-500/50  transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 transition duration-300 border-2 border-black-300 hover:border-blue-500"

            >
              <div class="text-5xl mb-4"></div>
              <h2 class="text-2xl font-bold text-black-900 mb-2">Registrar Turno</h2>
              <div class="mt-4 text-black-600 font-semibold">
                Registrar
              </div>
            </.link>

            <!-- Botón Display -->
            <.link
              navigate={~p"/display"}
              class="group flex flex-col items-center justify-center p-8 rounded-xl bg-purple-500/50  transition delay-150 duration-300 ease-in-out hover:-translate-y-1 hover:scale-110 transition duration-300 border-2 border-black-300 hover:border-purple-500"

            >
              <div class="text-5xl mb-4"></div>
              <h2 class="text-2xl font-bold text-black-900 mb-2">Pantalla Pública</h2>
              <div class="mt-4 text-black-600 font-semibold ">
                Ver
              </div>
            </.link>
          </div>

        </div>
      </div>
    </div>
    </div>
    """
  end
end
