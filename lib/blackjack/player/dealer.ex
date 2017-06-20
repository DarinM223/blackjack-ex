defmodule Blackjack.Player.Dealer do
  use GenServer

  alias Blackjack.Player
  alias Blackjack.Deck

  def start_link(id, opts \\ []) do
    GenServer.start_link(__MODULE__, id, opts)
  end

  def init(id) do
    Process.flag(:trap_exit, true)
    state = Blackjack.Player.Stash.get(Blackjack.Player.Stash, id)
    {:ok, state}
  end

  def handle_call(:turn, _from, state) do
    score = Player.Score.score(state.cards[0])
    action = if score >= 17, do: :stand, else: :hit
    {:reply, [action], state}
  end

  def handle_call(:cards, _from, state) do
    {:reply, state.cards, state}
  end

  def handle_cast(:deal, state) do
    cards = 1..2 |> Enum.map(fn _ -> Deck.draw(Deck) end)
    state = put_in(state.cards[0], cards)
    {:noreply, state}
  end

  def handle_cast({:hit, _}, state) do
    {:noreply, update_in(state.cards[0], &[Deck.draw(Deck) | &1])}
  end

  def handle_cast({:stand, _}, state), do: {:noreply, state}

  def terminate(_reason, state) do
    Blackjack.Player.Stash.save(Blackjack.Player.Stash, state.id, state)
  end
end
