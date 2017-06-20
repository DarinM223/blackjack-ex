defmodule Blackjack.Player.Stash do
  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, opts)
  end

  @default_money 100

  @doc """
  If player_id exists in stash, return the value in the stash,
  otherwise add a default value in the stash and return it.
  """
  def get(stash, id) do
    Agent.get_and_update(stash, fn stash ->
      if Map.has_key?(stash, id) do
        {Map.get(stash, id), stash}
      else
        player = Blackjack.Player.default(id, @default_money)
        stash = Map.put(stash, id, player)
        {player, stash}
      end
    end)
  end

  @doc """
  Saves a player state in the stash.
  """
  def save(stash, id, value) do
    Agent.update(stash, &Map.put(&1, id, value))
  end
end
