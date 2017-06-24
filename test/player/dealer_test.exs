defmodule DealerTest do
  use ExUnit.Case, async: true

  alias Blackjack.Player
  alias Blackjack.Testing

  setup context do
    deps = Testing.start(context.test)

    Player.Info.add(deps[:info], :dealer)
    {:ok, deps: deps}
  end

  test "dealer receives two cards on deal", %{deps: deps} do
    Player.deal(0, deps[:registry])
    assert length(Player.cards(0, deps[:registry])[0]) == 2
  end

  test "dealer adds card on hit", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.apply_action(0, 0, :hit, deps[:registry])
    assert length(Player.cards(0, deps[:registry])[0]) == 3
  end

  test "dealer stand does nothing", %{deps: deps} do
    Player.deal(0, deps[:registry])
    old_cards = Player.cards(0, deps[:registry])
    Player.apply_action(0, 0, :stand, deps[:registry])
    new_cards = Player.cards(0, deps[:registry])
    assert old_cards == new_cards
  end

  test "dealer hits if score < 17", %{deps: deps} do
    Player.deal(0, deps[:registry])
    assert Player.Score.score(Player.cards(0, deps[:registry])[0]) < 17
    assert Player.turn(0, deps[:registry]) == [:hit]
  end

  test "dealer stands if score >= 17", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Enum.each(1..4, fn _ -> Player.apply_action(0, 0, :hit, deps[:registry]) end)
    assert Player.Score.score(Player.cards(0, deps[:registry])[0]) >= 17
    assert Player.turn(0, deps[:registry]) == [:stand]
  end

  test "dealer reset removes cards", %{deps: deps} do
    Player.deal(0, deps[:registry])
    Player.reset(0, deps[:registry])
    assert Player.cards(0, deps[:registry]) == %{}
  end
end
