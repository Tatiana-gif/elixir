defmodule Turnos.Operators do
  @moduledoc """
  The Operators context.
  """

  import Ecto.Query, warn: false
  alias Turnos.Repo
  alias Turnos.Operators.Operator

  @doc """
  Get an operator by email and password.
  Only active operators can log in.
  """
  def get_operator_by_email_and_password(email, password) do
    operator = Repo.get_by(Operator, email: email)

    case operator do
      nil ->
        {:error, :invalid_email}

      operator ->
        # Check if operator is active
        if operator.status != "active" do
          {:error, :operator_inactive}
        else
          # Simple SHA256 comparison (for testing/demo)
          # In production, use proper bcrypt comparison
          hashed_input = :crypto.hash(:sha256, password) |> Base.encode16(case: :lower)

          if hashed_input == operator.hashed_password do
            {:ok, operator}
          else
            {:error, :invalid_password}
          end
        end
    end
  end

  @doc """
  Get an operator by ID.
  """
  def get_operator!(id) do
    Repo.get!(Operator, id)
  end

  @doc """
  Get an operator by email.
  """
  def get_operator_by_email(email) do
    Repo.get_by(Operator, email: email)
  end

  @doc """
  Create an operator.
  """
  def create_operator(attrs \\ %{}) do
    %Operator{}
    |> Operator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update an operator.
  """
  def update_operator(%Operator{} = operator, attrs) do
    operator
    |> Operator.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Delete an operator.
  """
  def delete_operator(%Operator{} = operator) do
    Repo.delete(operator)
  end

  @doc """
  Get all operators.
  """
  def list_operators do
    Repo.all(Operator)
  end

  @doc """
  Mark operator as online.
  """
  def mark_online(%Operator{} = operator) do
    operator
    |> Operator.update_changeset(%{
      "online_status" => "online",
      "last_seen_at" => NaiveDateTime.utc_now()
    })
    |> Repo.update()
  end

  @doc """
  Get an operator by module name.
  Returns the first active operator assigned to the module.
  """
  def get_operator_by_module(module) do
    Operator
    |> where([o], o.module == ^module and o.status == "active")
    |> first()
    |> Repo.one()
  end

  @doc """
  Mark operator as offline.
  """
  def mark_offline(%Operator{} = operator) do
    operator
    |> Operator.update_changeset(%{
      "online_status" => "offline",
      "last_seen_at" => NaiveDateTime.utc_now()
    })
    |> Repo.update()
  end
end
