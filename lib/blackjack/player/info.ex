defmodule Blackjack.Player.Info do
  @default_type Application.get_env(:blackjack, :default_player_type)

  def start_link(info) do
    info = info |> Enum.map(&convert_to_tuple/1)
    {max_id, _} = info |> Enum.max_by(fn {id, _} -> id end, fn -> {0, nil} end)
    Agent.start_link(fn -> %{info: info, curr_id: max_id + 1} end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn state -> state.info end)
  end

  def add(type \\ @default_type) do
    Agent.update(__MODULE__, fn %{info: info, curr_id: curr_id} ->
      %{info: [{curr_id, type} | info], curr_id: curr_id + 1}
    end)
  end

  def remove(id) do
    Agent.update(__MODULE__, fn state ->
      update_in(state.info, &delete_id(&1, id))
    end)
  end

  defp convert_to_tuple({id, type}), do: {id, type}
  defp convert_to_tuple(id), do: {id, @default_type}

  defp delete_id([], _), do: []
  defp delete_id([{curr_id, _} = h | t], id) do
    if curr_id == id do
      delete_id(t, id)
    else
      [h | delete_id(t, id)]
    end
  end
end