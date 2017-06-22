# TODO(DarinM223): remove
defmodule Blackjack.Player.Dealer do
  use GenServer

  require Logger

  alias Blackjack.Player
  alias Blackjack.Deck

  def start_link(id, deps, opts \\ []) do
    GenServer.start_link(__MODULE__, {id, deps}, opts)
  end

  def init({id, deps}) do
    Process.flag(:trap_exit, true)
    dealer = Blackjack.Player.Stash.get(deps[:stash], id)
    {:ok, {dealer, deps}}
  end

  def handle_call(:turn, _from, {dealer, _} = state) do
    Logger.debug("Blackjack.Player.Dealer :turn: state: #{inspect(dealer)}")
    score = Player.Score.score(dealer.cards[0])
    action = if score >= 17, do: :stand, else: :hit
    {:reply, [action], state}
  end

  def handle_call(:cards, _from, {dealer, _} = state) do
    Logger.debug("Blackjack.Player.Dealer :cards: state: #{inspect(dealer)}")
    {:reply, dealer.cards, state}
  end

  def handle_call(:reset, _from, {dealer, deps}) do
    Logger.debug("Blackjack.Player.Dealer :reset: state: #{inspect(dealer)}")
    dealer = Blackjack.Player.default(dealer.id, dealer.money)
    {:reply, :ok, {dealer, deps}}
  end

  def handle_cast(:deal, {dealer, deps}) do
    cards = Enum.map(1..2, fn _ -> Deck.draw(deps[:deck]) end)
    dealer = put_in(dealer.cards[0], cards)
    {:noreply, {dealer, deps}}
  end

  def handle_cast({:hit, _}, {dealer, deps}) do
    dealer = update_in(dealer.cards[0], &[Deck.draw(deps[:deck]) | &1])
    {:noreply, {dealer, deps}}
  end

  def handle_cast({:stand, _}, state), do: {:noreply, state}

  def terminate(_reason, {dealer, deps}) do
    Blackjack.Player.Stash.save(deps[:stash], dealer.id, dealer)
  end
end
