defmodule DealerTest do
  use ExUnit.Case, async: true

  alias Blackjack.Player
  alias Blackjack.Testing

  setup context do
    {:ok, _} = Testing.start(context.test)

    info = Testing.name(context.test, :info)
    Player.Info.add(info, :dealer)
    {:ok, test: context.test}
  end

  test "dealer receives two cards on deal", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    assert length(Player.cards(0, registry)[0]) == 2
  end

  test "dealer adds card on hit", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.apply_action(0, 0, :hit, registry)
    assert length(Player.cards(0, registry)[0]) == 3
  end

  test "dealer stand does nothing", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    old_cards = Player.cards(0, registry)
    Player.apply_action(0, 0, :stand, registry)
    new_cards = Player.cards(0, registry)
    assert old_cards == new_cards
  end

  test "dealer hits if score < 17", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    assert Player.Score.score(Player.cards(0, registry)[0]) < 17
    assert Player.turn(0, registry) == [:hit]
  end

  test "dealer stands if score >= 17", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Enum.each(1..4, fn _ -> Player.apply_action(0, 0, :hit, registry) end)
    assert Player.Score.score(Player.cards(0, registry)[0]) >= 17
    assert Player.turn(0, registry) == [:stand]
  end

  test "dealer reset removes cards", %{test: test} do
    registry = Testing.name(test, :registry)
    Player.deal(0, registry)
    Player.reset(0, registry)
    assert Player.cards(0, registry) == %{}
  end
end
