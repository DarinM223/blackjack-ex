defmodule Blackjack.Player.Worker do
  use GenServer

  require Logger

  alias Blackjack.Deck
  alias Blackjack.Player

  def start_link(deps, type, id, opts \\ []) do
    GenServer.start_link(__MODULE__, {deps, type, id}, opts)
  end

  # GenServer API

  def init({deps, type, id}) do
    # Modifies exits to call terminate().
    Process.flag(:trap_exit, true)
    player = Player.Stash.get(deps[:stash], id)
    {:ok, {type, player, deps}}
  end

  def handle_call(:turn, _from, {:dealer, dealer, _} = state) do
    Logger.debug("Blackjack.Player.Dealer :turn: state: #{inspect(dealer)}")
    score = Player.Score.score(dealer.cards[0])
    action = if score >= 17, do: :stand, else: :hit
    {:reply, [action], state}
  end

  def handle_call(:turn, _from, {_, player, _} = state) do
    Logger.debug("Blackjack.Player.Worker :turn: state: #{inspect(player)}")
    actions =
      player.cards
      |> Map.values
      |> Stream.map(&Player.Score.score/1)
      |> Enum.map(&ask_action/1)
    {:reply, actions, state}
  end

  def handle_call(:money, _from, {_, player, _} = state) do
    Logger.debug("Blackjack.Player.Worker :money: state: #{inspect(player)}")
    {:reply, player.money, state}
  end

  def handle_call(:cards, _from, {_, player, _} = state) do
    Logger.debug("Blackjack.Player.Worker :cards: state: #{inspect(player)}")
    {:reply, player.cards, state}
  end

  def handle_call(:ask_bet, _from, {_, player, _} = state) do
    Logger.debug("Blackjack.Player.Worker :ask_bet: state: #{inspect(player)}")
    bets = Enum.map(player.cards, fn _ -> ask_bet() end)
    {:reply, bets, state}
  end

  def handle_call(:reset, _from, {type, player, deps}) do
    Logger.debug("Blackjack.Player.Worker :reset: state: #{inspect(player)}")
    player = Player.default(player.id, player.money)
    {:reply, :ok, {type, player, deps}}
  end

  def handle_cast(:deal, {type, player, deps}) do
    Logger.debug("Blackjack.Player.Worker :deal: state: #{inspect(player)}")
    max_index = player.cards |> Map.keys |> Enum.max(fn -> -1 end)
    cards = Enum.map(1..2, fn _ -> Deck.draw(deps[:deck]) end)
    player = put_in(player.cards[max_index + 1], cards)
    {:noreply, {type, player, deps}}
  end

  def handle_cast({:hit, index}, {type, player, deps}) do
    Logger.debug("Blackjack.Player.Worker :hit: index: #{index} state: #{inspect(player)}")
    player = update_in(player.cards[index], &[Deck.draw(deps[:deck]) | &1])
    {:noreply, {type, player, deps}}
  end

  def handle_cast({:stand, _}, {_, player, _} = state) do
    Logger.debug("Blackjack.Player.Worker :stand: state: #{inspect(player)}")
    {:noreply, state}
  end

  def handle_cast({:double_down, index}, state) do
    raise "TODO: Implement this"
  end

  def handle_cast({:split, index}, state) do
    raise "TODO: Implement this"
  end

  def handle_cast({:win, index}, {type, player, deps}) do
    Logger.debug("Blackjack.Player.Worker :win: state: #{inspect(player)}")
    bet = player.bets[index]
    player = %{player | money: player.money + bet * 2}
    {:noreply, {type, player, deps}}
  end
  
  def handle_cast({:lose, _}, {_, player, _} = state) do
    Logger.debug("Blackjack.Player.Worker :lose: state: #{inspect(player)}")
    {:noreply, state}
  end

  def handle_cast({:push, index}, {type, player, deps}) do
    Logger.debug("Blackjack.Player.Worker :push: index: #{index} state: #{inspect(player)}")
    bet = player.bets[index]
    player = %{player | money: player.money + bet}
    {:noreply, {type, player, deps}}
  end

  def handle_cast({:bet, index, amount}, {type, player, deps}) do
    Logger.debug("Blackjack.Player.Worker :bet: index: #{index} amount: #{amount} state: #{inspect(player)}")
    player = %{player | money: player.money - amount,
                        bets: Map.put(player.bets, index, amount)}
    {:noreply, {type, player, deps}}
  end

  def terminate(_reason, {_, player, deps}) do
    Logger.debug("Blackjack.Player.Worker.terminate state: #{inspect(player)}")
    Blackjack.Player.Stash.save(deps[:stash], player.id, player)
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
