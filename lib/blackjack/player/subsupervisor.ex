defmodule Blackjack.Player.Subsupervisor do
  alias Blackjack.Player
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    supervise([], strategy: :one_for_one)
  end

  def add(id, type) do
    Supervisor.start_child(__MODULE__, make_worker(id, type))
  end

  defp make_worker(id, type) do
    name = Player.registry_name(id)
    worker(Player.worker_type(type),
           [id, [name: name]],
           [id: inspect(name), restart: :transient])
  end
end
