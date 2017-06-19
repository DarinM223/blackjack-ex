defmodule Blackjack.Player.Score do
  @moduledoc """
  Helper module for calculating the player's score.
  """

  alias Blackjack.Deck.Card

  def score(cards), do: _score(cards, 0, 0)

  defp _score([], score, _), do: score
  defp _score([%Card{value: value} | t], prev_score, num_high_aces) do
    {value, num_high_aces} = if value == 1 do
      {11, num_high_aces + 1}
    else
      {value, num_high_aces}
    end

    {new_score, num_high_aces} = _flatten_aces(prev_score + value, num_high_aces)
    _score(t, new_score, num_high_aces)
  end

  defp _flatten_aces(score, num_high_aces) do
    if score > 21 and num_high_aces > 0 do
      _flatten_aces(score - 10, num_high_aces - 1)
    else
      {score, num_high_aces}
    end
  end
end