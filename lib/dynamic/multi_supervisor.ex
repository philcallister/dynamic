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

      iex> Dynamic.Multi.Supervisor.start_child(Dynamic.Multi.One, "phil", "This is state")
      ...> Dynamic.Multi.Supervisor.toast("phil")
      :ok

  """
  def toast(name) do
    case Registry.lookup(Dynamic.Multi.Registry, name) do
      [{pid, module}] -> module.toast(pid)
      _ -> {:error, "Can't lookup process: #{name}"}
    end
  end

  @doc """
  Start a child process with the given `module`, `name`, and `state`

  Returns `{:ok, pid()}` | `{:error, String.t}` | `{:error, {:already_started, pid()}}`

  ## Examples

      iex> result = Dynamic.Multi.Supervisor.start_child(Dynamic.Multi.One, "phil", "This is state")
      ...> with {:ok, _pid} <- result, do: :passed

      iex> result = Dynamic.Multi.Supervisor.start_child(Dynamic.Multi.Nope, "ooops", "This fails")
      ...> with {:error, _string} <- result, do: :passed

  """
  def start_child(module, name, state) do
    case implemented_by?(module) do
      true ->
        spec = %{
          id: module,
          start: {module, :start_link, [%{state: state, name: name}]}
        }

        DynamicSupervisor.start_child(__MODULE__, spec)

      _ ->
        {:error, "Module '#{module}' doesn't implement 'Dynamic.Multi' behaviour"}
    end
  end

  # Server

  @impl true
  def init(state) do
    {:ok, state}
  end

  # Private

  # Check to see if the given module actually implements the behaviour as
  # defined within the Dynamic.Multi module.
  defp implemented_by?(module) do
    :attributes
    |> module.module_info()
    |> Enum.member?({:behaviour, [Dynamic.Multi]})
  end
end
