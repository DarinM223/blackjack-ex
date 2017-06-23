defmodule Blackjack.Testing do
  def start(test) do
    deps = [
      deck: :"#{test}_deck",
      stash: :"#{test}_stash",
      info: :"#{test}_info",
      subsupervisor: :"#{test}_subsupervisor",
      registry: :"#{test}_registry"
    ]
    Blackjack.Supervisor.start_link(deps)
  end

  def name(test, key) do
    :"#{test}_#{key}"
  end
end
