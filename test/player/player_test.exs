defmodule PlayerTest do
  use ExUnit.Case, async: false

  alias Blackjack.Player
  alias Blackjack.Deck

  setup do
    {:ok, player_supervisor} = Player.Supervisor.start_link([1, 2, 3])
    {:ok, deck_supervisor} = Deck.Supervisor.start_link
    on_exit fn ->
      assert_down(player_supervisor)
      assert_down(deck_supervisor)
    end
    {:ok, supervisor: player_supervisor}
  end

  test "player gets current money" do
    assert Player.money(1) == 100
  end

  test "player receives two cards on deal" do
    Player.deal(1)
    assert length(Player.cards(1)[0]) == 2
  end

  test "player loses money on bet" do
    Player.deal(1)
    Player.bet(1, 0, 50)
    assert Player.money(1) == 50
  end

  test "player gains double of bet money on win" do
    Player.deal(1)
    Player.bet(1, 0, 50)
    Player.apply_action(1, 0, :win)
    assert Player.money(1) == 150
  end

  test "player doesn't gain any money on lose" do
    Player.deal(1)
    Player.bet(1, 0, 50)
    Player.apply_action(1, 0, :lose)
    assert Player.money(1) == 50
  end

  test "player regains bet money on push" do
    Player.deal(1)
    Player.bet(1, 0, 50)
    Player.apply_action(1, 0, :push)
    assert Player.money(1) == 100
  end

  test "player adds card to hand on hit" do
    Player.deal(1)
    Player.apply_action(1, 0, :hit)
    assert length(Player.cards(1)[0]) == 3
  end

  test "player stand does nothing" do
    Player.deal(1)
    old_cards = Player.cards(1)
    Player.apply_action(1, 0, :stand)
    new_cards = Player.cards(1)
    assert old_cards == new_cards
  end

  @doc """
  Makes sure process is down before going to next test.
  """
  def assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end