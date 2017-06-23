defmodule Blackjack.Deck.Supervisor do
  use Supervisor

  def start_link(deps) do
    Supervisor.start_link(__MODULE__, deps)
  end

  def init(deps) do
    children = [worker(Blackjack.Deck, [[name: deps[:deck]]])]
    supervise(children, strategy: :one_for_one)
  end
end
