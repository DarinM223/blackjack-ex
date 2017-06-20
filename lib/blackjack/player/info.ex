defmodule Blackjack.Player.Info do
  use GenServer

  require Logger

  @default_type Application.get_env(:blackjack, :default_player_type)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, {[], [], 0}}
  end

  def get(info) do
    GenServer.call(info, :get)
  end

  def add(info, type \\ @default_type) do
    GenServer.call(info, {:add, type})
  end

  def handle_call(:get, _from, {info, _, _} = state) do
    {:reply, info, state}
  end

  def handle_call({:add, type}, _from, {info, refs, curr_id} = state) do
    Logger.debug("Blackjack.Player.Info :add: state: #{inspect(state)}")
    {:ok, player} = Blackjack.Player.Subsupervisor.add(curr_id, type)
    ref = Process.monitor(player)

    info = [{curr_id, type} | info]
    refs = [{curr_id, ref} | refs]
    {:reply, player, {info, refs, curr_id + 1}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {info, refs, curr_id} = state) do
    Logger.debug("Blackjack.Player.Info :DOWN: state: #{inspect(state)}")
    {id, _} = List.keyfind(refs, ref, 1)
    info = List.keydelete(info, id, 0)
    refs = List.keydelete(refs, id, 0)

    {:noreply, {info, refs, curr_id}}
  end
end
