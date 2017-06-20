defmodule Blackjack do
  @moduledoc """
  Documentation for Blackjack.
  """

  use Application
  require Logger

  alias Blackjack.Player

  def start(_type, _args) do
    Blackjack.Supervisor.start_link
  end

  def blackjack do
    Player.Info.add(Player.Info, :dealer)
    Player.Info.add(Player.Info)
    Player.Info.add(Player.Info)

    start_game()
    turns()
    check_wins()
    ask_leave()

    blackjack()
  end

  def start_game do
    Logger.debug("Blackjack.start:")
    info = Player.Info.get(Player.Info)

    Enum.each(info, fn {id, _} -> Player.deal(id) end)
    info
    |> Stream.filter(fn {_, type} -> type != :dealer end)
    |> Stream.map(fn {id, _} -> {id, Player.bet(id)} end)
    |> Stream.flat_map(&expand_actions/1)
    |> Enum.each(fn {id, index, bet} -> Player.bet(id, index, bet) end)
  end

  def turns do
    Logger.debug("Blackjack.turns:")
    Player.Info.get(Player.Info)
    |> Stream.map(fn {id, _} -> {id, Player.turn(id)} end)
    |> Stream.flat_map(&expand_actions/1)
    |> Enum.each(fn {id, index, action} -> Player.apply_action(id, index, action) end)
  end

  def check_wins do
    Logger.debug("Blackjack.check_wins:")
    info = Player.Info.get(Player.Info)
    [dealer_score] =
      info
      |> Stream.filter(fn {_, type} -> type == :dealer end)
      |> Stream.map(fn {id, _} -> Player.cards(id)[0] end)
      |> Stream.map(&Player.Score.score/1)
      |> Enum.take(1)

    info
    |> Stream.filter(fn {_, type} -> type != :dealer end)
    |> Stream.map(fn {id, _} -> {id, Player.cards(id)} end)
    |> Stream.flat_map(&expand_scores/1)
    |> Stream.map(fn {id, index, score} -> {id, index, player_won(score, dealer_score)} end)
    |> Enum.each(fn {id, index, action} -> Player.apply_action(id, index, action) end)
  end

  def ask_leave do
    Logger.debug("Blackjack.ask_leave:")
    Enum.each(Player.Info.get(Player.Info), &reset/1)
    ref = Process.monitor(Player.Subsupervisor)
    Supervisor.stop(Player.Subsupervisor)

    # Wait until subsupervisor is stopped.
    receive do {:DOWN, ^ref, _, _, _} -> nil end

    Logger.debug("Stopped player subsupervisor")

    # TODO(DarinM223): ask players if they want to leave
    # TODO(DarinM223): remove leaving players
  end

  defp reset({id, :dealer}), do: Player.Stash.reset(Player.Stash, id)
  defp reset({id, _}), do: Player.Stash.reset(Player.Stash, id, Player.money(id))

  defp player_won(score, dealer_score) do
    cond do
      score > 21 -> :lose
      dealer_score > 21 -> :win
      score == dealer_score -> :push
      score > dealer_score -> :win
      true -> :lose
    end
  end

  defp expand_actions({id, actions}) do
    {_, results} = Enum.reduce(actions, {0, []}, fn action, {index, results} ->
      {index + 1, [{id, index, action} | results]}
    end)

    Enum.reverse(results)
  end

  defp expand_scores({id, cards}) do
    Stream.map(cards, fn {index, hand} ->
      {id, index, Player.Score.score(hand)}
    end)
  end
end
