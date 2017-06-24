defmodule Blackjack.Testing do
  @moduledoc """
  Blackjack testing utilities.
  """

  @doc """
  Starts a separate blackjack supervisor to prevent
  race conditions with the main application.

  The names of all of the workers are dependent
  on the passed in test name and can be retrieved
  with Testing.name().
  """
  def start(test) do
    deps = [
      deck: :"#{test}_deck",
      stash: :"#{test}_stash",
      info: :"#{test}_info",
      subsupervisor: :"#{test}_subsupervisor",
      registry: :"#{test}_registry"
    ]
    {:ok, _} = Blackjack.Supervisor.start_link(deps)
    deps
  end

  @doc """
  Retrieves the test dependent name
  given the test name and the key.

  ## Examples

      iex> Blackjack.Testing.name("test", :deck)
      :test_deck

      iex> Blackjack.Testing.name("this is a test", :deck)
      :"this is a test_deck"

  """
  def name(test, key) do
    :"#{test}_#{key}"
  end
end
