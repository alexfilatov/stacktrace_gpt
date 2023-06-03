defmodule StacktraceGpt.Server do
  @moduledoc """
  This module is a GenServer that stores stacktraces in an ETS table and
  facilitates calls to ChatGPT to get explanations of those stacktraces.
  """
  use GenServer
  require Logger

  # this is the key for the ETS table
  @stacktraces_key :stacktraces

  @doc """
  Initiates the server process. It is linked to the current process and can be identified by the module name.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Initializes the server by logging its start and creating an ETS table named :stacktrace_gpt
  with protection type :protected. The table is public, uses the set data type, and is named.
  """
  def init(_) do
    Logger.info(
      "Starting StacktraceGpt, creating ETS table `:stacktrace_gpt` with key `#{@stacktraces_key}`"
    )

    {:ok, :ets.new(:stacktrace_gpt, [:named_table, :public, :set, :protected, :named_table])}
  end

  @spec add_stacktrace(binary() | list(), atom()) ::
          true | :not_dev_env | :message_format_not_supported
  @doc """
  Adds stacktrace message to the ETS table in `:dev` environment.
  `message` - is a string or a cons-cell-like list with an error message inside.
  The error message inside is extracted in the add_message_to_queue function.

  Returns `true` if successful.
  Returns `:not_dev_env` if not in `:dev` environment.
  Returns `:message_format_not_supported` if message is not a binary.
  """
  def add_stacktrace(message, env \\ Mix.env()) do
    case env do
      :dev ->
        add_message_to_queue(message)

      _ ->
        :not_dev_env
    end
  end

  @spec ask_gpt() :: :ok | :nothing_to_ask
  @doc """
  Gets the last message from the ETS table and asks GPT for explanation.
  """
  def ask_gpt() do
    case get_last_message_from_queue() do
      nil ->
        :nothing_to_ask

      message ->
        ask(message)
    end
  end

  @spec clear_stacktrace :: true
  @doc """
  Clears the ETS table.
  """
  def clear_stacktrace() do
    :ets.delete_all_objects(:stacktrace_gpt)
  end

  defp get_last_message_from_queue() do
    case :ets.lookup(:stacktrace_gpt, @stacktraces_key) do
      [] ->
        nil

      [{:stacktraces, [msg | _]}] ->
        msg
    end
  end

  # here we make a call to ChatGPT for stacktrace explanation
  defp ask(message) do
    Logger.debug("Asking GPT for stacktrace explanation...")

    # would be a great idea to make env var names configurable in case you
    # want to use this app with multiple OpenAI accounts
    config_override = %OpenAI.Config{
      api_key: System.get_env("OPENAI_API_KEY"),
      organization_key: System.get_env("OPENAI_ORGANIZATION_ID"),
      # https request timeout is 30 seconds by default, could be configurable in the future
      http_options: [recv_timeout: 30_000]
    }

    msg = ["Explain Elixir error: ", extract_stacktrace(message)] |> Enum.join("\n")

    OpenAI.chat_completion(
      [
        model: Application.get_env(:stacktrace_gpt, :model) || "gpt-3.5-turbo",
        messages: [%{role: "user", content: msg}]
      ],
      config_override
    )
    |> print_openai_response()

    :ok
  end

  defp print_openai_response(
         {:ok,
          %{
            choices: [%{"message" => %{"content" => reponse}}],
            usage: %{"total_tokens" => total_tokens}
          }}
       ) do
    Logger.debug("🤖👇👇👇")
    Logger.debug("#{IO.ANSI.yellow()}#{reponse}")
    Logger.debug("Tokens: #{total_tokens}")
    Logger.debug("🇺🇦")
  end

  defp print_openai_response(
         {:error,
          %{
            "error" => %{
              "message" => message,
              "type" => type
            }
          }}
       ) do
    Logger.debug("🤖👇👇👇")
    Logger.debug("#{IO.ANSI.red()}Error type: #{type}")
    Logger.debug("#{IO.ANSI.red()}Error message: #{message}")
    Logger.debug("🇺🇦")
  end

  defp extract_stacktrace([_ | t]), do: extract_stacktrace(t)
  defp extract_stacktrace(message), do: message

  defp add_message_to_queue(message) when is_binary(message) do
    case :ets.lookup(:stacktrace_gpt, @stacktraces_key) do
      [] ->
        :ets.insert(:stacktrace_gpt, {@stacktraces_key, [message]})

      [{@stacktraces_key, stacktrace}] ->
        :ets.insert(:stacktrace_gpt, {@stacktraces_key, [message | stacktrace]})
    end
  end

  defp add_message_to_queue([[_, _, _, [[_ | message] | _] | _] | _]),
    do: add_message_to_queue(message)

  defp add_message_to_queue([_, _, _, _, _, _ | message]),
    do: add_message_to_queue(message)

  defp add_message_to_queue(_), do: :message_format_not_supported
end
