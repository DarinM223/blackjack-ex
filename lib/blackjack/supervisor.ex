defmodule Blackjack.Supervisor do
  use Supervisor

  @registry Application.get_env(:blackjack, :default_registry)

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    deps = [
      deck: Blackjack.Deck,
      stash: Blackjack.Player.Stash,
      info: Blackjack.Player.Info,
      subsupervisor: Blackjack.Player.Subsupervisor,
      registry: @registry
    ]
    children = [
      supervisor(Blackjack.Player.Supervisor, [deps]),
      supervisor(Blackjack.Deck.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
