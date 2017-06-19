defmodule SupervisorTest do
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

  test "adds player to players" do
    Player.deal(1)
    Player.bet(1, 0, 50)
    Player.money(1)
    Player.Supervisor.add_player
    :timer.sleep(100)
    assert Player.money(4) == 100
    assert Player.money(1) == 50
  end

  test "removes player from players" do
    Player.deal(1)
    Player.bet(1, 0, 50)
    Player.Supervisor.remove_player(2)
    :timer.sleep(100)
    assert Player.money(1) == 50
    assert Player.money(3) == 100
  end

  @doc """
  Makes sure process is down before going to next test.
  """
  def assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end