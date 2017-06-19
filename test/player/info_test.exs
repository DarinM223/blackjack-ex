defmodule InfoTest do
  use ExUnit.Case

  alias Blackjack.Player.Info

  test "starting with array of ids" do
    {:ok, _} = Info.start_link([1, 2, 3])
    assert Info.get == [{1, :human}, {2, :human}, {3, :human}]
  end

  test "starting with array of (id, type) tuples" do
    {:ok, _} = Info.start_link([{1, :human}, {2, :human}, {3, :human}])
    assert Info.get == [{1, :human}, {2, :human}, {3, :human}]
  end

  test "add to empty array" do
    {:ok, _} = Info.start_link([])
    1..3 |> Enum.map(fn _ -> Info.add end)
    results = Info.get
    assert results |> List.keyfind(3, 0) != nil
    assert results |> List.keyfind(2, 0) != nil
    assert results |> List.keyfind(1, 0) != nil
  end

  test "add different types" do
    {:ok, _} = Info.start_link([])
    Info.add(:alien)
    Info.add(:borg)
    Info.add(:donkey)

    assert {1, :alien} in Info.get
    assert {2, :borg} in Info.get
    assert {3, :donkey} in Info.get
  end

  test "removes from array" do
    {:ok, _} = Info.start_link([1, 2, 3, 4])
    Info.remove(1)
    Info.remove(3)
    results = Info.get

    assert results |> List.keyfind(1, 0) == nil
    assert results |> List.keyfind(2, 0) != nil
    assert results |> List.keyfind(3, 0) == nil
    assert results |> List.keyfind(4, 0) != nil
  end
end