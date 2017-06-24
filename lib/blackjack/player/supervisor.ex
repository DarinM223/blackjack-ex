defmodule Blackjack.Player.Supervisor do
  @moduledoc """
  Supervisor for player related workers and supervisors.
  """

  use Supervisor

  @default_type Application.get_env(:blackjack, :default_player_type)

  def start_link(deps, opts \\ []) do
    Supervisor.start_link(__MODULE__, deps, opts)
  end

  def init(deps) do
    children = [
      supervisor(Registry, [:unique, deps[:registry]]),
      worker(Blackjack.Player.Stash, [[name: deps[:stash]]]),
      worker(Blackjack.Player.Info, [deps, [name: deps[:info]]]),
      supervisor(Blackjack.Player.Subsupervisor, [deps, [name: deps[:subsupervisor]]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
