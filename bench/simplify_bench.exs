defmodule SimplifyBench do
  use Benchfella

  @long Path.join([ "test", "fixtures", "large_linestring.wkt" ])
    |> File.read!
    |> Geo.WKT.decode

  @short [{0, 0}, {0.01, 0}, {0.5, 0.01}, {0.7, 0}, {1, 0}, {1.999, 0.999}, {2,1}]

  bench "long linestring - very low tolerance" do
    Simplify.simplify(@long, 0.00000001)
  end

  bench "long linestring - normal tolerance" do
    Simplify.simplify(@long, 0.00001)
  end

  bench "long linestring - high tolerance" do
    Simplify.simplify(@long, 0.1)
  end

  bench "long linestring - very high tolerance" do
    Simplify.simplify(@long, 1)
  end

  bench "long linestring - very very high tolerance" do
    Simplify.simplify(@long, 100)
  end

  bench "short linestring - high tolerance" do
    Simplify.simplify(@short, 0.1)
  end

  bench "short linestring - normal tolerance" do
    Simplify.simplify(@short, 0.009)
  end

  bench "short linestring - low tolerance" do
    Simplify.simplify(@short, 0.00001)
  end
end
