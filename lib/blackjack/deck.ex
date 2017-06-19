
defmodule Blackjack.Deck do
  alias Blackjack.Deck

  defmodule Card, do: defstruct value: nil, suite: nil, public: true

  @retry_time 1000

  # Public API

  @doc """
  Starts the deck worker.
  Should be called by a deck supervisor to handle
  crashes in the deck worker.
  """
  def start_link, do: Agent.start_link(fn -> new_deck() end, name: __MODULE__)

  @doc """
  Draws a card from the deck.
  If the deck worker crashes, it retries
  the draw call after waiting a certain period of time.
  """
  def draw(face_down \\ false) do
    try do
      if face_down do
        draw_private = fn [h | t] ->
          {%{h | public: false}, t}
        end
        Agent.get_and_update(__MODULE__, draw_private)
      else
        Agent.get_and_update(__MODULE__, fn [h | t] -> {h, t} end)
      end
    catch
      :exit, _ ->
        :timer.sleep(@retry_time)
        draw(face_down)
    end
  end

  defp new_deck do
    for value <- 1..13,
        suite <- [:hearts, :spades, :diamonds, :clubs] do
      %Deck.Card{value: value, suite: suite}
    end
  end
end
