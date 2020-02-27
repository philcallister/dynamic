defmodule Dynamic.Multi do
  @moduledoc """
  This behaviour is implemented within the children processes started by
  the Dynamic.Multi.Supervisor module
  """
  @callback toast(pid()) :: :ok
end
