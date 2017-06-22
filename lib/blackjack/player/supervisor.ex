defmodule Blackjack.Player.Supervisor do
  use Supervisor

  @default_type Application.get_env(:blackjack, :default_player_type)
  # TODO(DarinM223): refactor into config
  @registry :player_registry

  def start_link(deps) do
    Supervisor.start_link(__MODULE__, deps, name: __MODULE__)
  end

  def init(deps) do
    extra_deps = [
      stash: Blackjack.Player.Stash,
      info: Blackjack.Player.Info,
      subsupervisor: Blackjack.Player.Subsupervisor,
      registry: @registry 
    ]
    deps = deps ++ extra_deps

    children = [
      supervisor(Registry, [:unique, @registry]),
      worker(Blackjack.Player.Stash, [[name: Blackjack.Player.Stash]]),
      worker(Blackjack.Player.Info, [deps, [name: Blackjack.Player.Info]]),
      supervisor(Blackjack.Player.Subsupervisor, [deps, [name: Blackjack.Player.Subsupervisor]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
