# StacktraceGpt [![Build Status](https://github.com/alexfilatov/stacktrace_gpt/workflows/CI/badge.svg?branch=main)](https://github.com/alexfilatov/stacktrace_gpt/actions?query=workflow%3ACI) [![Hex pm](https://img.shields.io/hexpm/v/stacktrace_gpt.svg?style=flat)](https://hex.pm/packages/stacktrace_gpt) [![hex.pm downloads](https://img.shields.io/hexpm/dt/stacktrace_gpt.svg?style=flat)](https://hex.pm/packages/stacktrace_gpt)


Helps analyse Elixir/Phoenix stacktraces with help of ChatGPT.

## Installation

### Dependencies

The package can be installed by adding `stacktrace_gpt` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stacktrace_gpt, "~> 0.1", runtime: Mix.env() == :dev, only: :dev}
  ]
end
```
It has only one dependency - [openai.ex](https://github.com/mgallo/openai.ex)


## Configuration

#### Set OpenAI key in your dev environment

You can get your OpenAI key from https://platform.openai.com/account/api-keys, Organization ID you can grab here https://platform.openai.com/account/org-settings and set those in your development environment, e.g. in the `.env` file:

```bash
  export OPENAI_KEY=sk-...  
  export OPENAI_ORGANIZATION_ID=sk-...
```
then load this file into your environment with `source .env` command.

#### Add Logger backend to the dev.exs

```elixir
config :logger,
  backends: [StacktraceGpt.LoggerBackend, :console]
```

#### Configure ChatGPT model in the dev.exs

By default the model `gpt-3.5-turbo` is used. If you want to use another model for chat completions, you can set it in the config:

```elixir
config :stacktrace_gpt,
  model: "gpt-3.5-turbo"
```

#### Run mix task

```bash

mix stacktrace_gpt.install

```
This will create `.iex.exs` file in your project root (if doesn't exist) and following code to it:
  
  ```elixir
  # StacktraceGpt - GPT explanation of stacktraces when you have an error in iex console
# just type `gpt` right after you get an error and you will get an explanation from ChatGPT
  defmodule StacktraceGpt.Imports do
    def gpt, do: StacktraceGpt.Server.ask_gpt()
  end
  
  import StacktraceGpt.Imports
  
  require Logger
  Logger.info("StacktraceGpt is enabled! Type `gpt` after error to get an explanation from ChatGPT")
```
After this you can run your mix or phoenix project in the interactive console (`iex -S mix` or `iex -S mix phx.server`) and use `gpt` command in your iex console to get an explanation from ChatGPT for the last console error.


## About StacktraceGpt

StacktraceGpt is an Elixir-based tool that serves as a bridge between your application's error logs and OpenAI's powerful language GPT models. Using power of GPT, StacktraceGpt provides explanations for your application's error stack traces, enhancing your debugging and learning experience.

### The main components of StacktraceGpt

**StacktraceGpt.Server**: A GenServer that stores error stacktraces in an ETS table and retrieves explanations from ChatGPT. The server is identified by its module name and creates a public, named ETS table with protection type :protected.

**StacktraceGpt.Application**: The entry point of the application that starts the StacktraceGpt.Server.

**StacktraceGpt.LoggerBackend**: A Logger backend specifically designed for StacktraceGpt. It catches error logs, stores error messages in the ETS table, and passes them to the next Logger backend. This backend is meant to be used only in a development environment.


With StacktraceGpt, you can not only keep track of your application's errors but also receive understandable and detailed explanations for them, making it a great tool for both novice and experienced Elixir developers.

To use StacktraceGpt, you will need to have a paid OpenAI account and access to the GPT models. Please refer to the project's documentation for setup and usage instructions.


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/stacktrace_gpt](https://hexdocs.pm/stacktrace_gpt).

## License

The package is available as open source under the terms of the [MIT License](https://github.com/alexfilatov/stacktrace_gpt/LICENSE).