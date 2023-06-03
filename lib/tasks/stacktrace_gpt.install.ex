defmodule Mix.Tasks.StacktraceGpt.Install do
  use Mix.Task

  @shortdoc """
  Installs StacktraceGpt to .iex.exs in your project directory, so you can use an alias `gpt` in iex to get a GPT stacktrace explanation
  """

  def run(_) do
    # Get the root directory of the current Mix project
    # Construct the path to the .iex.exs file
    iex_file_path = Path.join(File.cwd!(), ".iex.exs")

    cmd = """

    # StacktraceGpt - GPT explanation of stacktraces when you have an error in iex console
    # just type `gpt` right after you get an error and you will get an explanation from ChatGPT
    defmodule StacktraceGpt.Imports do
      def gpt, do: StacktraceGpt.Server.ask_gpt()
    end
    import StacktraceGpt.Imports
    require Logger
    Logger.info("StacktraceGpt is enabled! Type `gpt` in your iex console after an error to get an explanation from ChatGPT")

    """

    File.write(iex_file_path, cmd, [:append])

    Mix.shell().info("Installed StacktraceGpt to .iex.exs")
  end
end
