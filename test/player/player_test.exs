defmodule PlayerTest do
  use ExUnit.Case, async: false

  alias Blackjack.Player

  setup do
    Application.stop(:blackjack)
    Application.start(:blackjack)

    Player.Info.add(Player.Info)
    Player.Info.add(Player.Info)
    Player.Info.add(Player.Info)
    :ok
  end

  test "player gets current money" do
    assert Player.money(0) == 100
  end

  test "player receives two cards on deal" do
    Player.deal(0)
    assert length(Player.cards(0)[0]) == 2
  end

  test "player loses money on bet" do
    Player.deal(0)
    Player.bet(0, 0, 50)
    assert Player.money(0) == 50
  end

  test "player gains double of bet money on win" do
    Player.deal(0)
    Player.bet(0, 0, 50)
    Player.apply_action(0, 0, :win)
    assert Player.money(0) == 150
  end

  test "player doesn't gain any money on lose" do
    Player.deal(0)
    Player.bet(0, 0, 50)
    Player.apply_action(0, 0, :lose)
    assert Player.money(0) == 50
  end

  test "player regains bet money on push" do
    Player.deal(0)
    Player.bet(0, 0, 50)
    Player.apply_action(0, 0, :push)
    assert Player.money(0) == 100
  end

  test "player adds card to hand on hit" do
    Player.deal(0)
    Player.apply_action(0, 0, :hit)
    assert length(Player.cards(0)[0]) == 3
  end

  test "player stand does nothing" do
    Player.deal(0)
    old_cards = Player.cards(0)
    Player.apply_action(0, 0, :stand)
    new_cards = Player.cards(0)
    assert old_cards == new_cards
  end
end
