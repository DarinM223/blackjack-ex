defmodule Blackjack.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Blackjack.Player.Supervisor, []),
      supervisor(Blackjack.Deck.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
