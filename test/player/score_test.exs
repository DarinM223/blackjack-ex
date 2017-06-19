defmodule ScoreTest do
  use ExUnit.Case

  import Blackjack.Player.Score
  alias Blackjack.Deck.Card

  test "score with no aces" do
    assert score([%Card{value: 2}, %Card{value: 3}, %Card{value: 4}]) == 9
  end

  test "score with aces using high and low score" do
    assert score([%Card{value: 1}, %Card{value: 1}]) == 12
  end

  test "score with previous ace reverting to low score" do
    assert score([%Card{value: 10}, %Card{value: 1}, %Card{value: 4}]) == 15
  end
end