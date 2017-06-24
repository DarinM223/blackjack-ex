defmodule Blackjack.Player do
  @moduledoc """
  Main player API.
  """

  require Logger

  @retry_time 100
  @default_registry Application.get_env(:blackjack, :default_registry)

  @doc """
  Returns a default player value.

  ## Example

      iex> Blackjack.Player.default(1, 100)
      %{id: 1, money: 100, cards: %{}, bets: %{}}

  """
  def default(id, money) do
    %{id: id, money: money, cards: %{}, bets: %{}}
  end

  @doc """
  Returns the player registry name from the player's id.

  ## Examples

      iex> Blackjack.Player.registry_name(0)
      {:via, Registry, {:player_registry, 0}}

      iex> Blackjack.Player.registry_name(0, :registry)
      {:via, Registry, {:registry, 0}}

  """
  def registry_name(id, registry \\ @default_registry) do
    {:via, Registry, {registry, id}}
  end

  @doc """
  Returns a list of actions for each of the player's hands.

  ## Example

      iex> test_name = "Blackjack.Player.turn doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info], :dealer)
      iex> Blackjack.Player.deal(0, deps[:registry])
      iex> Blackjack.Player.turn(0, deps[:registry])
      [:hit]

  """
  def turn(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.turn: id: #{id}")
    IO.puts("Player #{id}'s turn:")
    retry(&GenServer.call/3, [registry_name(id, registry), :turn, :infinity])
  end

  @doc """
  Prompts the user to input a bet.
  """
  def ask_bet(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.ask_bet: id: #{id}")
    IO.puts("Player #{id}'s bet")
    retry(&GenServer.call/3, [registry_name(id, registry), :ask_bet, :infinity])
  end

  @doc """
  Adds a given bet to the player's bets.
  """
  def bet(id, index, amount, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.bet: id: #{id}, index: #{index}, amount: #{amount}")
    retry(&GenServer.cast/2, [registry_name(id, registry), {:bet, index, amount}])
  end

  @doc """
  Returns the player's money.

  ## Example

      iex> test_name = "Blackjack.Player.money doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info])
      iex> Blackjack.Player.money(0, deps[:registry])
      100

  """
  def money(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.money: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id, registry), :money])
  end

  @doc """
  Returns the cards the player is holding.

  ## Example

      iex> test_name = "Blackjack.Player.cards doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info])
      iex> Blackjack.Player.cards(0, deps[:registry])
      %{}

  """
  def cards(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.cards: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id, registry), :cards])
  end

  @doc """
  Deals two cards to the player from the deck.

  ## Example

      iex> test_name = "Blackjack.Player.deal doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info])
      iex> Blackjack.Player.deal(0, deps[:registry])
      iex> Blackjack.Player.cards(0, deps[:registry])
      %{0 => [%Blackjack.Deck.Card{public: true, suite: :hearts, value: 1},
          %Blackjack.Deck.Card{public: true, suite: :spades, value: 1}]}

  """
  def deal(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.deal: id: #{id}")
    retry(&GenServer.cast/2, [registry_name(id, registry), :deal])
  end

  @doc """
  Resets the player's state except for the money.

  ## Example

      iex> test_name = "Blackjack.Player.reset doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info])
      iex> Blackjack.Player.deal(0, deps[:registry])
      iex> Blackjack.Player.bet(0, 0, 10, deps[:registry])
      iex> Blackjack.Player.reset(0, deps[:registry])
      iex> Blackjack.Player.cards(0, deps[:registry])
      %{}
      iex> Blackjack.Player.money(0, deps[:registry])
      90

  """
  def reset(id, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.reset: id: #{id}")
    retry(&GenServer.call/2, [registry_name(id, registry), :reset])
  end

  @doc """
  Applies certain actions like :hit, :stand, :win, :lose, :push, etc to the player.

  ## Example

      iex> test_name = "Blackjack.Player.apply_action doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info])
      iex> Blackjack.Player.bet(0, 0, 10, deps[:registry])
      iex> Blackjack.Player.apply_action(0, 0, :win, deps[:registry])
      iex> Blackjack.Player.money(0, deps[:registry]) # Should get double the bet money.
      110

  """
  def apply_action(id, index, action, registry \\ @default_registry) do
    Logger.debug("Blackjack.Player.apply_action: id: #{id}, index: #{index}, action: #{action}")
    retry(&GenServer.cast/2, [registry_name(id, registry), {action, index}])
  end

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
