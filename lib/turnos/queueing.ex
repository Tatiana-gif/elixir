defmodule Turnos.Queueing do
  @moduledoc """
  The Queueing context.
  """

  import Ecto.Query, warn: false
  alias Turnos.Repo

  alias Turnos.Queueing.Queue

  @doc """
  Returns the list of queues.

  ## Examples

      iex> list_queues()
      [%Queue{}, ...]

  """
  def list_queues do
    Repo.all(Queue)
  end

  @doc """
  List queues assigned to a specific operator.
  """
  def list_queues_for_operator(operator_id) do
    import Ecto.Query, warn: false

    Repo.all(
      from q in Queue, where: q.operator_id == ^operator_id, order_by: [asc: q.inserted_at]
    )
  end

  @doc """
  Preassign up to `count` pending turnos to an operator (status -> "assigned").
  Returns the list of assigned queues.
  """
  def preassign_turns(operator_id, count \\ 3) when is_integer(count) and count > 0 do
    import Ecto.Query, warn: false

    pending =
      Repo.all(
        from q in Queue, where: q.status == "pending", order_by: q.inserted_at, limit: ^count
      )

    assigned =
      Enum.map(pending, fn q ->
        q
        |> Queue.changeset(%{status: "assigned", operator_id: operator_id})
        |> Repo.update!()
      end)

    Enum.each(assigned, fn q ->
      Phoenix.PubSub.broadcast(Turnos.PubSub, "queues", {:queue_updated, q})
    end)

    assigned
  end

  @doc """
  Subscribe the current process to queue updates.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Turnos.PubSub, "queues")
  end

  @doc """
  Call the next pending queue and assign it to an operator.
  Returns `{:ok, %Queue{}}` or `{:error, :no_pending}`.
  """
  def call_next(operator_id) do
    import Ecto.Query, warn: false

    pending =
      Repo.one(from q in Queue, where: q.status == "pending", order_by: q.inserted_at, limit: 1)

    if pending do
      pending
      |> Queue.changeset(%{status: "calling", operator_id: operator_id})
      |> Repo.update()
      |> broadcast_change()
    else
      {:error, :no_pending}
    end
  end

  defp broadcast_change({:ok, queue} = ok) do
    Phoenix.PubSub.broadcast(Turnos.PubSub, "queues", {:queue_updated, queue})
    ok
  end

  defp broadcast_change(other), do: other

  @doc """
  Mark a called queue as being attended.
  """
  def mark_attending(queue_id) do
    case Repo.get(Queue, queue_id) do
      nil ->
        {:error, :not_found}

      queue ->
        queue
        |> Queue.changeset(%{status: "attending"})
        |> Repo.update()
        |> broadcast_change()
    end
  end

  @doc """
  Gets a single queue.

  Raises `Ecto.NoResultsError` if the Queue does not exist.

  ## Examples

      iex> get_queue!(123)
      %Queue{}

      iex> get_queue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_queue!(id), do: Repo.get!(Queue, id)

  @doc """
  Creates a queue.

  ## Examples

      iex> create_queue(%{field: value})
      {:ok, %Queue{}}

      iex> create_queue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_queue(attrs) do
    %Queue{}
    |> Queue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a queue.

  ## Examples

      iex> update_queue(queue, %{field: new_value})
      {:ok, %Queue{}}

      iex> update_queue(queue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_queue(%Queue{} = queue, attrs) do
    queue
    |> Queue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a queue.

  ## Examples

      iex> delete_queue(queue)
      {:ok, %Queue{}}

      iex> delete_queue(queue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_queue(%Queue{} = queue) do
    Repo.delete(queue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking queue changes.

  ## Examples

      iex> change_queue(queue)
      %Ecto.Changeset{data: %Queue{}}

  """
  def change_queue(%Queue{} = queue, attrs \\ %{}) do
    Queue.changeset(queue, attrs)
  end
end
