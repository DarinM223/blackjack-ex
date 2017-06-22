defmodule Blackjack.Player do
  @moduledoc """
  Main player API.
  """

  require Logger

  @retry_time 100
  # TODO(DarinM223): refactor into config
  @default_registry :player_registry

  @doc """
  Returns a default player value.
  """
  def default(id, money) do
    %{id: id, money: money, cards: %{}, bets: %{}}
  end

  @doc """
  Looks up player's name from id.
  """
  def registry_name(id, registry \\ @default_registry) do
    {:via, Registry, {registry, id}}
  end

  def turn(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.turn: id: #{id}")
    IO.puts("Player #{id}'s turn:")
    retry(&GenServer.call/3, [registry_name(id, registry), :turn, :infinity])
  end

  def ask_bet(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.ask_bet: id: #{id}")
    IO.puts("Player #{id}'s bet")
    retry(&GenServer.call/3, [registry_name(id, registry), :ask_bet, :infinity])
  end

  def bet(id, index, amount, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.bet: id: #{id}, index: #{index}, amount: #{amount}")
    retry(&GenServer.cast/2, [registry_name(id, registry), {:bet, index, amount}])
  end

  def money(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.money: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id, registry), :money])
  end

  def cards(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.cards: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id, registry), :cards])
  end

  def deal(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.deal: id: #{id}")
    retry(&GenServer.cast/2, [registry_name(id, registry), :deal])
  end

  def reset(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.reset: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id, registry), :reset])
  end

  def apply_action(id, index, action, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.apply_action: id: #{id}, index: #{index}, action: #{action}")
    retry(&GenServer.cast/2, [registry_name(id, registry), {action, index}])
  end

  @doc """
  Retries GenServer operation if it fails.
  """
  defp retry(f, args) do
    # TODO(DarinM223): use exponential backoff and
    # fail after certain amount of retries.
    try do
      Kernel.apply(f, args)
    catch 
      :exit, _ ->
        Logger.debug("Retrying #{inspect(f)}, #{inspect(args)}")
        :timer.sleep(@retry_time)
        retry(f, args)
    end
  end
end
