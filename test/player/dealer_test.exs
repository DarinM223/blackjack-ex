defmodule DealerTest do
  use ExUnit.Case, async: false

  alias Blackjack.Player

  setup do
    Application.stop(:blackjack)
    Application.start(:blackjack)

    Player.Info.add(Player.Info, :dealer)
    :ok
  end

  test "dealer receives two cards on deal" do
    Player.deal(0)
    assert length(Player.cards(0)[0]) == 2
  end

  test "dealer adds card on hit" do
    Player.deal(0)
    Player.apply_action(0, 0, :hit)
    assert length(Player.cards(0)[0]) == 3
  end

  test "dealer stand does nothing" do
    Player.deal(0)
    old_cards = Player.cards(0)
    Player.apply_action(0, 0, :stand)
    new_cards = Player.cards(0)
    assert old_cards == new_cards
  end

  test "dealer hits if score < 17" do
    Player.deal(0)
    assert Player.Score.score(Player.cards(0)[0]) < 17
    assert Player.turn(0) == [:hit]
  end

  test "dealer stands if score >= 17" do
    Player.deal(0)
    Enum.each(1..4, fn _ -> Player.apply_action(0, 0, :hit) end)
    assert Player.Score.score(Player.cards(0)[0]) >= 17
    assert Player.turn(0) == [:stand]
  end

  test "dealer reset removes cards" do
    Player.deal(0)
    Player.reset(0)
    assert Player.cards(0) == %{}
  end
end
