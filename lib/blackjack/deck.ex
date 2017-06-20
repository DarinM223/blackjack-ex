
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
  def start_link(opts \\ []) do
    Agent.start_link(fn -> new_deck() end, opts)
  end

  @doc """
  Draws a card from the deck.
  If the deck worker crashes, it retries
  the draw call after waiting a certain period of time.
  """
  def draw(deck, face_down \\ false) do
    try do
      Agent.get_and_update(deck, fn
        [h | t] when face_down -> {%{h | public: false}, t}
        [h | t] -> {h, t}
      end)
    catch
      :exit, _ ->
        :timer.sleep(@retry_time)
        draw(deck, face_down)
    end
  end

  defp new_deck do
    for value <- 1..13,
        suite <- [:hearts, :spades, :diamonds, :clubs] do
      %Deck.Card{value: value, suite: suite}
    end
  end
end
