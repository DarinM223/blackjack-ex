defmodule Blackjack.Deck.Supervisor do
  @moduledoc """
  Supervises the deck worker.
  """

  use Supervisor

  def start_link(deps, opts \\ []) do
    Supervisor.start_link(__MODULE__, deps, opts)
  end

  def init(deps) do
    children = [worker(Blackjack.Deck, [[name: deps[:deck]]])]
    supervise(children, strategy: :one_for_one)
  end
end
