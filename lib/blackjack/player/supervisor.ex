defmodule Blackjack.Player.Supervisor do
  use Supervisor

  @default_type Application.get_env(:blackjack, :default_player_type)

  def start_link(ids) do
    Supervisor.start_link(__MODULE__, ids, name: __MODULE__)
  end

  def init(ids) do
    children = [
      supervisor(Registry, [:unique, :player_registry]),
      worker(Blackjack.Player.Stash, []),
      worker(Blackjack.Player.Info, [ids]),
      supervisor(Blackjack.Player.Subsupervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

  def add_player(type \\ @default_type) do
    Blackjack.Player.Info.add(type)
    Blackjack.Player.Subsupervisor.stop
  end

  def remove_player(id) do
    Blackjack.Player.Info.remove(id)
    Blackjack.Player.Subsupervisor.stop
  end
end