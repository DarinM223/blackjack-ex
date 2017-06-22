defmodule InfoTest do
  use ExUnit.Case, async: false

  alias Blackjack.Player.Info
  alias Blackjack.Player.Subsupervisor

  require Logger

  setup do
    Application.stop(:blackjack)
    Application.start(:blackjack)

    {:ok, info} = Info.start_link([subsupervisor: Subsupervisor])
    {:ok, info: info}
  end

  test "add to empty array", %{info: info} do
    Enum.map(1..3, fn _ -> Info.add(info) end)
    results = Info.get(info)
    assert List.keyfind(results, 2, 0) != nil
    assert List.keyfind(results, 1, 0) != nil
    assert List.keyfind(results, 0, 0) != nil
  end

  test "add different types", %{info: info} do
    Info.add(info, :alien)
    Info.add(info, :borg)
    Info.add(info, :donkey)

    assert {0, :alien} in Info.get(info)
    assert {1, :borg} in Info.get(info)
    assert {2, :donkey} in Info.get(info)
  end

  test "removes from array", %{info: info} do
    0..3
    |> Stream.map(fn id -> {id, Info.add(info)} end)
    |> Enum.each(&kill_process(&1, [0, 2]))

    results = Info.get(info)

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
