defmodule InfoTest do
  use ExUnit.Case, async: true

  doctest Blackjack.Player.Info

  alias Blackjack.Player.Info
  alias Blackjack.Testing

  require Logger

  setup context do
    deps = Testing.start(context.test)
    {:ok, deps: deps}
  end

  test "add to empty array", %{deps: deps} do
    Enum.map(1..3, fn _ -> Info.add(deps[:info]) end)
    results = Info.get(deps[:info])
    assert List.keyfind(results, 2, 0) != nil
    assert List.keyfind(results, 1, 0) != nil
    assert List.keyfind(results, 0, 0) != nil
  end

  test "add different types", %{deps: deps} do
    Info.add(deps[:info], :alien)
    Info.add(deps[:info], :borg)
    Info.add(deps[:info], :donkey)

    result = Info.get(deps[:info])
    assert {0, :alien} in result
    assert {1, :borg} in result
    assert {2, :donkey} in result
  end

  test "removes from array", %{deps: deps} do
    0..3
    |> Stream.map(fn id -> {id, Info.add(deps[:info])} end)
    |> Enum.each(&kill_process(&1, [0, 2]))

    results = Info.get(deps[:info])

    Logger.debug("results: #{inspect results}")

    assert List.keyfind(results, 0, 0) == nil
    assert List.keyfind(results, 1, 0) != nil
    assert List.keyfind(results, 2, 0) == nil
    assert List.keyfind(results, 3, 0) != nil
  end

  defp kill_process({id, process}, kill_list) do
    Logger.debug("Process: #{inspect process}")
    ref = Process.monitor(process)
    if id in kill_list do
      GenServer.stop(process)
      assert_receive {:DOWN, ^ref, _, _, _}
    end
  end
end
