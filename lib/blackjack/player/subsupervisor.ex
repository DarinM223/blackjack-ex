defmodule Blackjack.Player.Subsupervisor do
  alias Blackjack.Player
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    info = Player.Info.get
    children = info |> Enum.map(&make_worker/1)

    supervise(children, strategy: :one_for_one)
  end

  def stop, do: Supervisor.stop(__MODULE__)

  defp make_worker({id, type}) do
    name = Player.registry_name(id)
    worker(Player.worker_type(type), [id, [name: name]], id: inspect(name))
  end
end