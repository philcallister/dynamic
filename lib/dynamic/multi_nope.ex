defmodule Dynamic.Multi.Nope do
  @moduledoc """
  A child process not started by the `Dynamic.Multi.Supervisor` module. This module
  DOES NOT implement the `Dynamic.Multi behaviour`, so it can't be called by
  the proxy.
  """

  use GenServer

  ## Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(state[:name]))
  end

  ## Server

  @impl true
  def init(state) do
    {:ok, state}
  end

  ## Private

  defp via_tuple(name) do
    {:via, Registry, {Dynamic.Multi.Registry, name, __MODULE__}}
  end
end
