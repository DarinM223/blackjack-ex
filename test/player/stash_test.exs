defmodule StashTest do
  use ExUnit.Case

  alias Blackjack.Player.Stash

  setup do
    {:ok, pid} = Stash.start_link
    {:ok, stash: pid}
  end

  test "get with no existing id will create default player" do
    assert Stash.get(1) == %{id: 1, money: 100, cards: %{}, bets: %{}}
  end

  test "get with existing id will return saved player data" do
    player = Stash.get(1)
    Stash.save(player.id, %{player | money: 1})
    assert Stash.get(player.id) == %{id: 1, money: 1, cards: %{}, bets: %{}}
  end

  test "reset will reset player with updated money" do
    player = Stash.get(1)
    Stash.reset(player.id, 1)
    assert Stash.get(player.id) == %{id: 1, money: 1, cards: %{}, bets: %{}}
  end
end