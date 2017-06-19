defmodule Blackjack.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      supervisor(Blackjack.Player.Supervisor, [[{1, :dealer}, 2, 3]]),
      supervisor(Blackjack.Deck.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end