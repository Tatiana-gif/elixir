defmodule Turnos.QueueingTest do
  use Turnos.DataCase

  alias Turnos.Queueing

  describe "queues" do
    alias Turnos.Queueing.Queue

    import Turnos.QueueingFixtures

    @invalid_attrs %{status: nil, number: nil}

    test "list_queues/0 returns all queues" do
      queue = queue_fixture()
      assert Queueing.list_queues() == [queue]
    end

    test "get_queue!/1 returns the queue with given id" do
      queue = queue_fixture()
      assert Queueing.get_queue!(queue.id) == queue
    end

    test "create_queue/1 with valid data creates a queue" do
      valid_attrs = %{status: "some status", number: 42}

      assert {:ok, %Queue{} = queue} = Queueing.create_queue(valid_attrs)
      assert queue.status == "some status"
      assert queue.number == 42
    end

    test "create_queue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Queueing.create_queue(@invalid_attrs)
    end

    test "update_queue/2 with valid data updates the queue" do
      queue = queue_fixture()
      update_attrs = %{status: "some updated status", number: 43}

      assert {:ok, %Queue{} = queue} = Queueing.update_queue(queue, update_attrs)
      assert queue.status == "some updated status"
      assert queue.number == 43
    end

    test "update_queue/2 with invalid data returns error changeset" do
      queue = queue_fixture()
      assert {:error, %Ecto.Changeset{}} = Queueing.update_queue(queue, @invalid_attrs)
      assert queue == Queueing.get_queue!(queue.id)
    end

    test "delete_queue/1 deletes the queue" do
      queue = queue_fixture()
      assert {:ok, %Queue{}} = Queueing.delete_queue(queue)
      assert_raise Ecto.NoResultsError, fn -> Queueing.get_queue!(queue.id) end
    end

    test "change_queue/1 returns a queue changeset" do
      queue = queue_fixture()
      assert %Ecto.Changeset{} = Queueing.change_queue(queue)
    end
  end
end
