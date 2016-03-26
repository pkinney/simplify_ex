defmodule Simplify do
  def simplify(coordinates, tolerance) when is_list(coordinates) do
    simplifyDPStep(coordinates, tolerance * tolerance)
  end

  def simplify(%Geo.LineString{} = linestring, tolerance) do
    %Geo.LineString{coordinates: simplify(linestring.coordinates, tolerance)}
  end

  defp simplifyDPStep(segment, _) when length(segment) < 3, do: segment
  defp simplifyDPStep(segment, toleranceSquared) do
    first = List.first(segment)
    last = List.last(segment)

    {farIndex, _, farSquaredDist} =
      Enum.zip(0..(length(segment)-1), segment)
      |> Enum.slice(1..(length(segment) - 2))
      |> Enum.map(fn({i, p}) -> { i, p, Distance.segment_distance_squared(p, first, last)} end)
      |> Enum.max_by(&(elem(&1, 2)))

    if farSquaredDist > toleranceSquared do
      front = simplifyDPStep(Enum.slice(segment, 0..farIndex), toleranceSquared)
      [ _ | back ] = simplifyDPStep(Enum.slice(segment, farIndex..length(segment)), toleranceSquared)

      front ++ back
    else
      [ first, last ]
    end
  end
end
