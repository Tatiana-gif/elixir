defmodule Turnos.Operators.Operator do
  use Ecto.Schema
  import Ecto.Changeset

  schema "operators" do
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true, redact: true
    field :name, :string
    field :status, :string, default: "inactive"
    field :confirmed_at, :naive_datetime
    field :module, :string, default: "Sin asignar"
    field :online_status, :string, default: "offline"
    field :last_seen_at, :naive_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(operator, attrs) do
    operator
    |> cast(attrs, [:email, :password, :name, :status, :module, :online_status, :last_seen_at])
    |> validate_required([:email, :password])
    |> validate_email()
    |> validate_length(:password, min: 6)
    |> hash_password()
    |> unique_constraint(:email)
  end

  def update_changeset(operator, attrs) do
    operator
    |> cast(attrs, [:name, :status, :module, :online_status, :last_seen_at])
    |> validate_required([:name])
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && password != "" do
      # For now, simple hash using SHA256 (for testing)
      # In production, use bcrypt_elixir with proper setup
      hashed = :crypto.hash(:sha256, password) |> Base.encode16(case: :lower)
      put_change(changeset, :hashed_password, hashed)
    else
      changeset
    end
  end
end
