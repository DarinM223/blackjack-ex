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

  def start_blackjack do
    Player.Info.add(Player.Info, Player.Subsupervisor, :dealer)
    Player.Info.add(Player.Info, Player.Subsupervisor)
    Player.Info.add(Player.Info, Player.Subsupervisor)

    blackjack()
  end

  defp blackjack do
    start_game()
    turns()
    check_wins()
    ask_leave()

    blackjack()
  end

  defp start_game do
    Logger.debug("Blackjack.start:")
    info = Player.Info.get(Player.Info)

    Enum.each(info, fn {id, _} -> Player.deal(id) end)
    info
    |> Stream.filter(fn {_, type} -> type != :dealer end)
    |> Stream.map(fn {id, _} -> {id, Player.ask_bet(id)} end)
    |> Stream.flat_map(&expand_actions/1)
    |> Enum.each(fn {id, index, bet} -> Player.bet(id, index, bet) end)
  end

  defp turns do
    Logger.debug("Blackjack.turns:")
    Player.Info.get(Player.Info)
    |> Stream.map(fn {id, _} -> {id, Player.turn(id)} end)
    |> Stream.flat_map(&expand_actions/1)
    |> Enum.each(fn {id, index, action} -> Player.apply_action(id, index, action) end)
  end

  defp check_wins do
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

  defp ask_leave do
    Logger.debug("Blackjack.ask_leave:")
    Player.Info.get(Player.Info)
    |> Stream.map(fn {id, type} -> {Player.reset(id), id, type} end)
    |> Enum.each(&ask_leave/1)
  end

  defp ask_leave({:ok, _, :dealer}), do: :ok

  defp ask_leave({:ok, id, :human}) do
    input = IO.gets("Do you want to leave? (y/n)") |> String.trim
    case input do
      "y" -> GenServer.stop(Player.registry_name(id))
      "n" -> :ok
      _ -> ask_leave({:ok, id, :player})
    end
  end

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
