defmodule Blackjack.Player.Subsupervisor do
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

  def add(subsupervisor, id, type, deps) do
    name = Player.registry_name(id, deps[:registry])
    Logger.debug("Adding id: #{inspect(id)}, type: #{inspect(type)} as name: #{inspect(name)}")
    Supervisor.start_child(subsupervisor, [type, id, [name: name]])
  end
end
