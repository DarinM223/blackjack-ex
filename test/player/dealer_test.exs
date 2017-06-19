defmodule DealerTest do
  use ExUnit.Case, async: false

  alias Blackjack.Player
  alias Blackjack.Deck

  setup do
    {:ok, player_supervisor} = Player.Supervisor.start_link([{1, :dealer}])
    {:ok, deck_supervisor} = Deck.Supervisor.start_link
    on_exit fn ->
      assert_down(player_supervisor)
      assert_down(deck_supervisor)
    end
    {:ok, supervisor: player_supervisor}
  end

  test "dealer receives two cards on deal" do
    Player.deal(1)
    assert length(Player.cards(1)[0]) == 2
  end

  test "dealer adds card on hit" do
    Player.deal(1)
    Player.apply_action(1, 0, :hit)
    assert length(Player.cards(1)[0]) == 3
  end

  test "dealer stand does nothing" do
    Player.deal(1)
    old_cards = Player.cards(1)
    Player.apply_action(1, 0, :stand)
    new_cards = Player.cards(1)
    assert old_cards == new_cards
  end

  test "dealer hits if score < 17" do
    Player.deal(1)
    assert Player.Score.score(Player.cards(1)[0]) < 17
    assert Player.turn(1) == [:hit]
  end

  test "dealer stands if score >= 17" do
    Player.deal(1)
    1..4 |> Enum.each(fn _ -> Player.apply_action(1, 0, :hit) end)
    assert Player.Score.score(Player.cards(1)[0]) >= 17
    assert Player.turn(1) == [:stand]
  end

  @doc """
  Makes sure process is down before going to next test.
  """
  def assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end