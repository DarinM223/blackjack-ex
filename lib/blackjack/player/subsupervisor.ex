defmodule Blackjack.Player.Subsupervisor do
  @moduledoc """
  Supervisor for player workers.
  Workers are dynamically started in the supervisor
  through the simple one for one supervision strategy.
  """

  alias Blackjack.Player
  use Supervisor

  require Logger

  def start_link(deps, opts \\ []) do
    Supervisor.start_link(__MODULE__, deps, opts)
  end

  def init(deps) do
    children = [
      worker(Player.Worker, [deps], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Adds a player worker to the supervisor.
  """
  def add(subsupervisor, id, type) do
    Logger.debug("Adding id: #{inspect(id)}, type: #{inspect(type)}")
    Supervisor.start_child(subsupervisor, [type, id])
  end
end
