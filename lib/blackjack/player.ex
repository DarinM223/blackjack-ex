defmodule Blackjack.Player do
  @moduledoc """
  Main player API.
  """

  require Logger

  @retry_time 100

  @doc """
  Looks up player's name from id.
  """
  def registry_name(id) do
    {:via, Registry, {:player_registry, id}}
  end

  def turn(id) do
    Logger.debug("Blackjack.Player.turn: id: #{id}")
    IO.puts("Player #{id}'s turn:")
    retry(&GenServer.call/3, [registry_name(id), :turn, :infinity])
  end

  def bet(id) do
    Logger.debug("Blackjack.Player.bet: id: #{id}")
    IO.puts("Player #{id}'s bet")
    retry(&GenServer.call/3, [registry_name(id), :bet, :infinity])
  end

  def bet(id, index, amount) do
    Logger.debug("Blackjack.Player.bet: id: #{id}, index: #{index}, amount: #{amount}")
    retry(&GenServer.cast/2, [registry_name(id), {:bet, index, amount}])
  end

  def money(id) do
    Logger.debug("Blackjack.Player.money: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id), :money])
  end

  def cards(id) do
    Logger.debug("Blackjack.Player.cards: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id), :cards])
  end

  def deal(id) do
    Logger.debug("Blackjack.Player.deal: id: #{id}")
    retry(&GenServer.cast/2, [registry_name(id), :deal])
  end

  def apply_action(id, index, action) do
    Logger.debug("Blackjack.Player.apply_action: id: #{id}, index: #{index}, action: #{action}")
    retry(&GenServer.cast/2, [registry_name(id), {action, index}])
  end

  def worker_type(:human), do: Blackjack.Player.Worker
  def worker_type(:dealer), do: Blackjack.Player.Dealer
  def worker_type(_), do: Blackjack.Player.Worker

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
