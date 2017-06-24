defmodule Blackjack.Supervisor do
  @moduledoc """
  The main supervisor for the Blackjack application.
  Supervises the player supervisor and the deck supervisor.
  """

  use Supervisor

  @registry Application.get_env(:blackjack, :default_registry)
  @default_deps [
    deck: Blackjack.Deck,
    stash: Blackjack.Player.Stash,
    info: Blackjack.Player.Info,
    subsupervisor: Blackjack.Player.Subsupervisor,
    registry: @registry
  ]

  def start_link(deps \\ @default_deps) do
    Supervisor.start_link(__MODULE__, deps)
  end

  def init(deps) do
    children = [
      supervisor(Blackjack.Player.Supervisor, [deps]),
      supervisor(Blackjack.Deck.Supervisor, [deps])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
