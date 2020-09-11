defmodule Gos.MixProject do
  use Mix.Project

  def project do
    [
      app: :gos,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Gos.Application, []}
    ]
  end

  defp deps do
    [
      {:telemetry, "> 0.0.0"}
    ]
  end
end
