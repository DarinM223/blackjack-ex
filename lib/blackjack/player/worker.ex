defmodule Blackjack.Player.Worker do
  use GenServer

  require Logger

  alias Blackjack.Player
  alias Blackjack.Deck

  def start_link(id, opts \\ []) do
    GenServer.start_link(__MODULE__, id, opts)
  end

  # GenServer API

  def init(id) do
    # Modifies exits to call terminate().
    Process.flag(:trap_exit, true)
    state = Blackjack.Player.Stash.get(id)
    {:ok, state}
  end

  def handle_call(:turn, _from, %{cards: cards} = state) do
    Logger.debug("Blackjack.Player.Worker :turn: state: #{inspect(state)}")
    actions =
      cards
      |> Map.values
      |> Stream.map(&Player.Score.score/1)
      |> Enum.map(&ask_action/1)
    {:reply, actions, state}
  end

  def handle_call(:money, _from, state) do
    Logger.debug("Blackjack.Player.Worker :money: state: #{inspect(state)}")
    {:reply, state.money, state}
  end

  def handle_call(:cards, _from, state) do
    Logger.debug("Blackjack.Player.Worker :cards: state: #{inspect(state)}")
    {:reply, state.cards, state}
  end

  def handle_call(:bet, _from, state) do
    Logger.debug("Blackjack.Player.Worker :bet: state: #{inspect(state)}")
    bets = Enum.map(state.cards, fn _ -> ask_bet() end)
    {:reply, bets, state}
  end

  def handle_cast(:deal, state) do
    Logger.debug("Blackjack.Player.Worker :deal: state: #{inspect(state)}")
    max_index = state.cards |> Map.keys |> Enum.max(fn -> -1 end)
    cards = 1..2 |> Enum.map(fn _ -> Deck.draw end)
    state = put_in(state.cards[max_index + 1], cards)
    {:noreply, state}
  end

  def handle_cast({:hit, index}, state) do
    Logger.debug("Blackjack.Player.Worker :hit: index: #{index} state: #{inspect(state)}")
    {:noreply, update_in(state.cards[index], &[Deck.draw | &1])}
  end

  def handle_cast({:stand, _}, state) do
    Logger.debug("Blackjack.Player.Worker :stand: state: #{inspect(state)}")
    {:noreply, state}
  end

  def handle_cast({:double_down, index}, state) do
    raise "TODO: Implement this"
  end

  def handle_cast({:split, index}, state) do
    raise "TODO: Implement this"
  end

  def handle_cast({:win, index}, state) do
    Logger.debug("Blackjack.Player.Worker :win: state: #{inspect(state)}")
    bet = state.bets[index]
    {:noreply, %{state | money: state.money + bet * 2}}
  end
  
  def handle_cast({:lose, _}, state) do
    Logger.debug("Blackjack.Player.Worker :lose: state: #{inspect(state)}")
    {:noreply, state}
  end

  def handle_cast({:push, index}, state) do
    Logger.debug("Blackjack.Player.Worker :push: index: #{index} state: #{inspect(state)}")
    bet = state.bets[index]
    {:noreply, %{state | money: state.money + bet}}
  end

  def handle_cast({:bet, index, amount}, state) do
    Logger.debug("Blackjack.Player.Worker :bet: index: #{index} amount: #{amount} state: #{inspect(state)}")
    {:noreply, %{state | money: state.money - amount,
                         bets: Map.put(state.bets, index, amount)}}
  end

  def terminate(_reason, state) do
    Logger.debug("Blackjack.Player.Worker.terminate state: #{inspect(state)}")
    Blackjack.Player.Stash.save(state.id, state)
  end

  defp ask_action(_) do
    actions = [hit: 0, stand: 1]

    IO.puts("Available actions: ")
    Enum.each(actions, fn {action, input} ->
      IO.puts("#{input}: #{action}")
    end)

    {action_num, _} = IO.gets("Enter the action:") |> Integer.parse
    {action, _} = List.keyfind(actions, action_num, 1)
    action
  end

  defp ask_bet do
    {bet_amount, _} = IO.gets("Enter the bet amount:") |> Integer.parse
    bet_amount
  end
end