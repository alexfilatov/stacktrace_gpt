defmodule StacktraceGpt.LoggerBackend do
  @moduledoc """
  Logger backend for StacktraceGpt

  The purpose of this backend is to catch only errors, store error messages in the ETS table to form a LIFO queue
  and pass them to the next Logger backend.

  This backend should be only used in development environment,
  so it's not included in the list of backends in `config.exs` but rather in `dev.exs`:

  ```elixir
  # config/dev.exs

  config :logger,
    backends: [:console, StacktraceGpt.LoggerBackend]
  ```
  """
  @behaviour :gen_event

  @impl true
  def init(params) do
    {:ok, params}
  end

  @impl true
  def handle_call(_, state) do
    {:ok, :ok, state}
  end

  @doc """
  This is where we add stacktrace to the ETS table and pass error to the next Logger backend
  """
  @impl true
  def handle_event({:error, _group_leader, {Logger, message, _timestamp, _metadata}}, state) do
    StacktraceGpt.Server.add_stacktrace(message)
    {:ok, state}
  end

  def handle_event({_level, _group_leader, {Logger, _message, _timestamp, _metadata}}, state) do
    # catch all other events
    {:ok, state}
  end

  @impl true
  def handle_info(_, state) do
    {:ok, state}
  end
end
