defmodule Simplify.Mixfile do
  use Mix.Project

  def project do
    [app: :simplify,
     version: "0.1.0",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},
      {:geo, "~> 1.0"},
      {:distance, "~> 0.1.0"},
      {:excoveralls, "~> 0.4", only: :test}
    ]
  end

  defp description do
    """
    Implementation of the Ramer–Douglas–Peucker algorithm for reducing the number of points used to represent a curve.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Powell Kinney"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pkinney/simplify_ex"}
    ]
  end
end
