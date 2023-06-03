defmodule StacktraceGpt.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {StacktraceGpt.Server, []}
    ]

    opts = [strategy: :one_for_one, name: StacktraceGpt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
