defmodule Simplify do
  @type point :: {number, number}

  @spec simplify(list(point), number) :: list(point)
  def simplify(coordinates, tolerance) when is_list(coordinates) do
    simplify_dp_step(coordinates, tolerance * tolerance)
  end

  @spec simplify(%Geo.LineString{}, number) :: %Geo.LineString{}
  def simplify(%Geo.LineString{} = linestring, tolerance) do
    %Geo.LineString{coordinates: simplify(linestring.coordinates, tolerance)}
  end

  defp simplify_dp_step(segment, _) when length(segment) < 3, do: segment

  defp simplify_dp_step(segment, tolerance_squared) do
    first = List.first(segment)
    last = List.last(segment)

    {far_index, _, far_squared_dist} =
      Enum.zip(0..(length(segment) - 1), segment)
      |> Enum.drop(1)
      |> Enum.drop(-1)
      |> Enum.map(fn {i, p} -> {i, p, seg_dist(p, first, last)} end)
      |> Enum.max_by(&elem(&1, 2))

    if far_squared_dist > tolerance_squared do
      front = simplify_dp_step(Enum.take(segment, far_index + 1), tolerance_squared)
      [_ | back] = simplify_dp_step(Enum.drop(segment, far_index), tolerance_squared)

      front ++ back
    else
      [first, last]
    end
  end

  defp seg_dist({px, py, _}, {ax, ay, _}, {bx, by, _}), do: seg_dist({px, py}, {ax, ay}, {bx, by})
  defp seg_dist(p, a, b), do: Distance.segment_distance_squared(p, a, b)
end
