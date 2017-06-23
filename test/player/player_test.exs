defmodule PlayerTest do
  use ExUnit.Case, async: true

  alias Blackjack.Player
  alias Blackjack.Testing

  setup context do
    {:ok, _} = Testing.start(context.test)

    info = Testing.name(context.test, :info)
    Player.Info.add(info)
    Player.Info.add(info)
    Player.Info.add(info)
    {:ok, test: context.test}
  end

  test "player gets current money", %{test: test} do
    registry = Testing.name(test, :registry)
    assert Player.money(0, registry) == 100
  end

  test "player receives two cards on deal", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    assert length(Player.cards(0, registry)[0]) == 2
  end

  test "player loses money on bet", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.bet(0, 0, 50, registry)
    assert Player.money(0, registry) == 50
  end

  test "player gains double of bet money on win", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.bet(0, 0, 50, registry)
    Player.apply_action(0, 0, :win, registry)
    assert Player.money(0, registry) == 150
  end

  test "player doesn't gain any money on lose", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.bet(0, 0, 50, registry)
    Player.apply_action(0, 0, :lose, registry)
    assert Player.money(0, registry) == 50
  end

  test "player regains bet money on push", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.bet(0, 0, 50, registry)
    Player.apply_action(0, 0, :push, registry)
    assert Player.money(0, registry) == 100
  end

  test "player adds card to hand on hit", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.apply_action(0, 0, :hit, registry)
    assert length(Player.cards(0, registry)[0]) == 3
  end

  test "player stand does nothing", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    old_cards = Player.cards(0, registry)
    Player.apply_action(0, 0, :stand, registry)
    new_cards = Player.cards(0, registry)
    assert old_cards == new_cards
  end

  test "player reset removes cards", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.bet(0, 0, 50, registry)
    Player.apply_action(0, 0, :win, registry)
    Player.reset(0, registry)
    assert Player.money(0, registry) == 150
    assert Player.cards(0, registry) == %{}
  end
end
