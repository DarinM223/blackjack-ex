# Blackjack

A blackjack game in Elixir where everything is an OTP actor.

The supervision tree of the project:
![Supervision tree](http://i.imgur.com/MdG16eF.png)

Some things learned about Elixir and OTP:
* The Registry supervisor given in the standard library is useful for naming multiple processes created dynamically and managed by a supervisor. For example, a registry is used to name blackjack players by id. That way it is easy to send messages to the player from an id if the registry name is known.
* If it is necessary to get a list of currently running dynamically created processes it is a good idea to create another process to keep track of their names, because it is not easy for supervisors to list their currently supervising processes and supervisors should have as little logic as possible. The Process.monitor function allows the other process to keep track of the running processes and remove them from the list if they unexpectedly shut down. The Blackjack.Player.Info worker is an example of this type of process.
* When a process crashes because of an exception it loses all of its state. However, since in Elixir everything is immutable the process will often not be in an invalid state when it crashes. In that case it is a good idea for the crashing process to save the state in another "stash" process before it terminates and then load the state when it restarts. Blackjack.Player.Stash is an example of a stash process that saves state for crashing player processes.
* When every process needs to call other processes in the supervision tree, passing in the other process names into each process instead of globally naming processes makes it easier to test because you can start multiple supervision trees at once without race conditions and not have to worry about starting and stopping one global supervision tree for each test. It also makes it easier to set up the processes across multiple machines.
* Simple one-for-one supervisors allow you to specify a template worker with some parameters filled in. Then you can specify the rest of the parameters later when you create the worker. This is useful when you want to dynamically start a worker in a supervisor but you need to pass in data specified at the initialization of the supervisor. For example, in Blackjack.Player.Subsupervisor, the function to dynamically start a worker doesn't need to pass in the process names because they were already passed in the template.
* Console input won't work in an iex shell if the worker asking for the input is a subworker of a background application. To see an example, type ```iex -S mix``` into the console and then type ```Blackjack.start_blackjack``` into the prompt. It will ask for user input but the prompt will be frozen. This doesn't happen when the blackjack supervisor is started inside the iex prompt instead of as an application.
* Module attributes are only accessible in the same module, so one way to have global constants is to put them in config/config.exs and call ```Application.get_env(:project, :constant_name)``` to retrieve them.
* A way to "debug" code is to use Logger and log messages received, functions called, etc. The logger can be configured to strip out certain types of logs at compile time so the log messages won't show unless you are debugging.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blackjack` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:blackjack, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/blackjack](https://hexdocs.pm/blackjack).

