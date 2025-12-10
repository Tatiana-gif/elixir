defmodule Turnos.QueueingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Turnos.Queueing` context.
  """

  @doc """
  Generate a queue.
  """
  def queue_fixture(attrs \\ %{}) do
    {:ok, queue} =
      attrs
      |> Enum.into(%{
        number: 42,
        status: "some status"
      })
      |> Turnos.Queueing.create_queue()

    queue
  end
end
