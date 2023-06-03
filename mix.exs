defmodule StacktraceGpt.MixProject do
  use Mix.Project

  def project do
    [
      app: :stacktrace_gpt,
      version: "0.1.2",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :dev,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {StacktraceGpt.Application, []}
    ]
  end

  defp description do
    """
    Helps analyse Elixir/Phoenix stacktraces with help of ChatGPT
    """
  end

  defp package do
    [
      maintainers: ["Alex Filatov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/alexfilatov/stacktrace_gpt",
        "Docs" => "https://hexdocs.pm/stacktrace_gpt"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev},
      {:openai, "~> 0.5"}
    ]
  end
end
