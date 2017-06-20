defmodule Blackjack.Player.Supervisor do
  use Supervisor

  @default_type Application.get_env(:blackjack, :default_player_type)

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Registry, [:unique, :player_registry]),
      worker(Blackjack.Player.Stash, [[name: Blackjack.Player.Stash]]),
      worker(Blackjack.Player.Info, [[name: Blackjack.Player.Info]]),
      supervisor(Blackjack.Player.Subsupervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
