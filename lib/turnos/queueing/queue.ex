defmodule Turnos.Queueing.Queue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "queues" do
    field :number, :integer
    field :status, :string
    field :module, :string
    field :operator_id, :id
    field :completed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(queue, attrs) do
    queue
    |> cast(attrs, [:number, :status, :module, :operator_id, :completed_at])
    |> validate_required([:number])
    |> validate_inclusion(:status, ["pending", "waiting", "attending", "completed"],
      message: "debe ser pending, waiting, attending o completed"
    )
  end
end
