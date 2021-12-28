defmodule AdventOfCode.MixProject do
  use Mix.Project

  def project() do
    [
      app: :adventofcode,
      version: "0.0.1",
      elixir: "~> 1.0",
      deps: deps(),
    ]
  end

def application do
  [
    extra_applications: [:logger]
  ]
end

  defp deps() do
    [
      {:priority_queue, "~> 1.0.0"},
    ]
  end
end