defmodule PlayerTest do
  use ExUnit.Case, async: true

  doctest Blackjack.Player

  alias Blackjack.Player
  alias Blackjack.Testing

  setup context do
    deps = Testing.start(context.test)

    Player.Info.add(deps[:info])
    Player.Info.add(deps[:info])
    Player.Info.add(deps[:info])
    {:ok, deps: deps}
  end

  test "player gets current money", %{deps: deps} do
    assert Player.money(0, deps[:registry]) == 100
  end

  test "player receives two cards on deal", %{deps: deps} do
    Player.deal(0, deps[:registry])
    assert length(Player.cards(0, deps[:registry])[0]) == 2
  end

  test "player loses money on bet", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.bet(0, 0, 50, deps[:registry])
    assert Player.money(0, deps[:registry]) == 50
  end

  test "player gains double of bet money on win", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.bet(0, 0, 50, deps[:registry])
    Player.apply_action(0, 0, :win, deps[:registry])
    assert Player.money(0, deps[:registry]) == 150
  end

  test "player doesn't gain any money on lose", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.bet(0, 0, 50, deps[:registry])
    Player.apply_action(0, 0, :lose, deps[:registry])
    assert Player.money(0, deps[:registry]) == 50
  end

  test "player regains bet money on push", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.bet(0, 0, 50, deps[:registry])
    Player.apply_action(0, 0, :push, deps[:registry])
    assert Player.money(0, deps[:registry]) == 100
  end

  test "player adds card to hand on hit", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.apply_action(0, 0, :hit, deps[:registry])
    assert length(Player.cards(0, deps[:registry])[0]) == 3
  end

  test "player stand does nothing", %{deps: deps} do
    Player.deal(0, deps[:registry])
    old_cards = Player.cards(0, deps[:registry])
    Player.apply_action(0, 0, :stand, deps[:registry])
    new_cards = Player.cards(0, deps[:registry])
    assert old_cards == new_cards
  end

  test "player reset removes cards", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.bet(0, 0, 50, deps[:registry])
    Player.apply_action(0, 0, :win, deps[:registry])
    Player.reset(0, deps[:registry])
    assert Player.money(0, deps[:registry]) == 150
    assert Player.cards(0, deps[:registry]) == %{}
  end
end
