defmodule Dynamic.Multi.One do
  @moduledoc """
  A child process started by the `Dynamic.Multi.Supervisor` module. This module
  implements the `Dynamic.Multi behaviour` which is then "polymorphically"
  called via the `Dynamic.Multi.Supervisor.toast/1` function.
  """
  @behaviour Dynamic.Multi

  use GenServer

  ## Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(state[:name]))
  end

  @impl Dynamic.Multi
  def toast(pid) do
    GenServer.call(pid, :toast)
  end

  ## Server

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:toast, _from, state) do
    IO.puts("\"ONE: #{state[:state]}\"")
    {:reply, :ok, state}
  end

  ## Private

  defp via_tuple(name) do
    # Adding the __MODULE__ here as the value, so it can be retrieved within
    # the Dynamic.Multi.Supervisor.toast function when the Registry
    # lookup is perfomed. This will provide the "fake" polymorphism.
    {:via, Registry, {Dynamic.Multi.Registry, name, __MODULE__}}
  end
end
