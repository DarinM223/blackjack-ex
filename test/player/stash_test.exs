defmodule StashTest do
  use ExUnit.Case

  alias Blackjack.Player.Stash

  setup do
    {:ok, stash} = Stash.start_link
    {:ok, stash: stash}
  end

  test "get with no existing id will create default player", %{stash: stash} do
    assert Stash.get(stash, 1) == %{id: 1, money: 100, cards: %{}, bets: %{}}
  end

  test "get with existing id will return saved player data", %{stash: stash} do
    player = Stash.get(stash, 1)
    Stash.save(stash, player.id, %{player | money: 1})
    assert Stash.get(stash, player.id) == %{id: 1, money: 1, cards: %{}, bets: %{}}
  end

  test "reset will reset player with updated money", %{stash: stash} do
    player = Stash.get(stash, 1)
    Stash.reset(stash, player.id, 1)
    assert Stash.get(stash, player.id) == %{id: 1, money: 1, cards: %{}, bets: %{}}
  end
end
