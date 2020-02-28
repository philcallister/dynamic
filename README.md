# Dynamic - Supervision with "Fake" Polymorphism

  This is just a simple attempt to create dynamically supervised children which
  can be called in a "fake" polymorphic way. There might be much better ways to
  do this, so if there is, let me know!

  For this example, the idea is that different **types** of children could be
  supervised together, then called polymorphically, without knowing anything
  about the actual child.

  To do this, a child is started through the supervisor. When the child
  initializes, it registers itself and its `__MODULE__` within the `Registry`.
  After it's started, it can be invoked through a proxy, by the same supervisor
  that started it.  If, however, a child doesn't implement the defined
  behaviour, it won't be started by the supervisor.

### Installation
```sh
$ mix deps.get
$ mix deps.compile
```
### Run It
Once you've got all the dependencies pulled, start it up within `iex` so you can
start some child processes
```sh
iex -S mix run
```
Now that you're within `iex`, you can start some children. Try the following
```elixir
iex(1)> Dynamic.Multi.Supervisor.start_child(Dynamic.Multi.One, "phil", "This is state")
{:ok, #PID<0.175.0>}
iex(2)> Dynamic.Multi.Supervisor.start_child(Dynamic.Multi.Two, "amy", "This is state too")
{:ok, #PID<0.178.0>}
iex(3)> Dynamic.Multi.Supervisor.start_child(Dynamic.Multi.Nope, "ooops", "This fails")
{:error, "Module 'Elixir.Dynamic.Multi.Nope' doesn't implement 'Dynamic.Multi' behaviour"}
iex(4)> Dynamic.Multi.Supervisor.toast("phil")
"ONE: This is state"
:ok
iex(5)> Dynamic.Multi.Supervisor.toast("amy")
"TWO: This is state too"
:ok
```
That's about it. You're starting two children of different types. When you call
`toast/1` with the child's name, it invokes the proxy within the supervisor. The
proxy then looks up the child within the `Registry` and calls the child's
`toast/1` function. Done!
