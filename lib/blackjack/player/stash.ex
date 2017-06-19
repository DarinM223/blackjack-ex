defmodule Blackjack.Player.Stash do
  def start_link, do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @default_money 100

  @doc """
  If player_id exists in stash, return the value in the stash,
  otherwise add a default value in the stash and return it.
  """
  def get(id) do
    Agent.get_and_update(__MODULE__, fn stash ->
      if Map.has_key?(stash, id) do
        {Map.get(stash, id), stash}
      else
        player = default_player(id)
        stash = stash |> Map.put(id, player)
        {player, stash}
      end
    end)
  end

  @doc """
  Resets the player data with the option of passing
  in an updated money value to the reset player.
  """
  def reset(id, money \\ @default_money) do
    save(id, default_player(id, money))
  end

  @doc """
  Saves a player state in the stash.
  """
  def save(id, value) do
    Agent.update(__MODULE__, &Map.put(&1, id, value))
  end

  defp default_player(id, money \\ @default_money) do
    %{id: id, money: money, cards: %{}, bets: %{}}
  end
end
