defmodule StacktraceGpt.ServerTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias StacktraceGpt.Server

  setup do
    Server.clear_stacktrace()
    :ok
  end

  test "init/1 logs start and creates ETS table" do
    log_msg =
      "Starting StacktraceGpt, creating ETS table `:stacktrace_gpt` with key `stacktraces`"

    captured_log = capture_log(fn -> :ok = GenServer.stop(StacktraceGpt.Server) end)
    assert Regex.match?(~r/#{Regex.escape(log_msg)}/, captured_log)

    assert :ets.info(:stacktrace_gpt) != :undefined
  end

  test "add_stacktrace/2 adds stacktrace to ETS table in :dev environment" do
    assert Server.add_stacktrace("test message", :dev) == true
    assert {:stacktraces, ["test message"]} = hd(:ets.tab2list(:stacktrace_gpt))
  end

  test "add_stacktrace/2 does not add stacktrace in non-:dev environment" do
    assert Server.add_stacktrace("test message", :prod) == :not_dev_env
    assert :ets.tab2list(:stacktrace_gpt) == []
  end

  test "add_stacktrace/2 does not support non-binary message" do
    assert Server.add_stacktrace(123, :dev) == :message_format_not_supported
  end

  test "clear_stacktrace/0 clears the ETS table" do
    Server.add_stacktrace("test message", :dev)
    assert Server.clear_stacktrace() == true
    assert :ets.tab2list(:stacktrace_gpt) == []
  end

  test "ask_gpt/0 returns :nothing_to_ask if ETS table is empty" do
    Server.clear_stacktrace()
    assert Server.ask_gpt() == :nothing_to_ask
  end

  test "ask_gpt/0 asks GPT for explanation if ETS table is not empty" do
    Server.add_stacktrace("test message", :dev)
    assert Server.ask_gpt() == :ok
  end
end
