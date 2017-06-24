defmodule Blackjack.Player.Info do
  @moduledoc """
  Stores the ids and types of the running player workers.
  """

  use GenServer

  require Logger

  @default_type Application.get_env(:blackjack, :default_player_type)

  def start_link(deps, opts \\ []) do
    GenServer.start_link(__MODULE__, deps, opts)
  end

  @doc """
  Returns the player info.

  ## Example

      iex> test_name = "Blackjack.Player.Info.get doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.get(deps[:info])
      []

  """
  def get(info) do
    GenServer.call(info, :get)
  end

  @doc """
  Adds a player to the info.

  ## Example

      iex> test_name = "Blackjack.Player.Info.get default doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info])
      iex> Blackjack.Player.Info.get(deps[:info])
      [{0, :human}]

      iex> test_name = "Blackjack.Player.Info.get dealer doctest"
      iex> deps = Blackjack.Testing.start(test_name)
      iex> Blackjack.Player.Info.add(deps[:info], :dealer)
      iex> Blackjack.Player.Info.get(deps[:info])
      [{0, :dealer}]

  """
  def add(info, type \\ @default_type) do
    GenServer.call(info, {:add, type})
  end

  def init(deps) do
    {:ok, {[], [], 0, deps}}
  end

  def handle_call(:get, _from, {info, _, _, _} = state) do
    {:reply, info, state}
  end

  def handle_call({:add, type}, _from, {info, refs, curr_id, deps} = state) do
    Logger.debug("Blackjack.Player.Info :add: state: #{inspect(state)}")
    {:ok, player} = Blackjack.Player.Subsupervisor.add(deps[:subsupervisor], curr_id, type)
    ref = Process.monitor(player)

    info = [{curr_id, type} | info]
    refs = [{curr_id, ref} | refs]
    {:reply, player, {info, refs, curr_id + 1, deps}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {info, refs, curr_id, deps} = state) do
    Logger.debug("Blackjack.Player.Info :DOWN: state: #{inspect(state)}")
    {id, _} = List.keyfind(refs, ref, 1)
    info = List.keydelete(info, id, 0)
    refs = List.keydelete(refs, id, 0)

    {:noreply, {info, refs, curr_id, deps}}
  end
end
