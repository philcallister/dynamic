defmodule Dynamic.Multi.Supervisor do
  @moduledoc """
  This is the supervisor for the dynamic children processes started here,
  and it's also a proxy to the children processes via the `toast/1` function.
  """
  use DynamicSupervisor

  # Client

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, [init_arg], name: __MODULE__)
  end

  @doc """
  "toast" a child process with the given `name`.

  First, a `Registry.lookup/2` is
  preformed with the given `name`. If a pid is returned, the registry value,
  (added within the child as a module), is called with the `toast/1`
  behaviour defined within `Dynamic.Multi`

  Returns `:ok` | `{:error, String.t}`

  ## Examples

    iex> Dynamic.Multi.Supervisor.toast("phil")
    :ok

  """
  def toast(name) do
    case Registry.lookup(Dynamic.Multi.Registry, name) do
      [{pid, module}] -> module.toast(pid)
      _ -> {:error, "Can't lookup process: #{name}"}
    end
  end

  @doc """
  Start a child process ONE with the given `name` and `state`

  Returns `{:ok, pid()}` | `{:error, {:already_started, pid()}}`

  ## Examples

    iex> Dynamic.Multi.Supervisor.start_child_one("phil", "This is state")
    {:ok, pid()}

  """
  def start_child_one(name, state) do
    spec = %{
      id: Dynamic.Multi.One,
      start: {Dynamic.Multi.One, :start_link, [%{state: state, name: name}]}
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
  Start a child process TWO with the given `name` and `state`

  Returns `{:ok, pid()}` | `{:error, {:already_started, pid()}}`

  ## Examples

    iex> Dynamic.Multi.Supervisor.start_child_two("amy", "This is state")
    {:ok, pid()}

  """
  def start_child_two(name, state) do
    spec = %{
      id: Dynamic.Multi.Two,
      start: {Dynamic.Multi.Two, :start_link, [%{state: state, name: name}]}
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # Server

  @impl true
  def init(state) do
    {:ok, state}
  end
end
