defmodule SimplifyBench do
  use Benchfella

  @ring Path.join([ "test", "fixtures", "large_linestring.wkt" ])
    |> File.read!
    |> Geo.WKT.decode

  bench "very low tolerance" do
    Simplify.simplify(@ring, 0.00000001)
  end

  bench "normal tolerance" do
    Simplify.simplify(@ring, 0.00001)
  end

  bench "high tolerance" do
    Simplify.simplify(@ring, 0.1)
  end

  bench "very high tolerance" do
    Simplify.simplify(@ring, 1)
  end

  bench "very very high tolerance" do
    Simplify.simplify(@ring, 100)
  end
end
