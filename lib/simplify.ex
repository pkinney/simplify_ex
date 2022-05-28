defmodule Simplify do
  @type point :: {number, number}

  @spec simplify(list(point), number) :: list(point)
  def simplify(coordinates, tolerance) when is_list(coordinates) do
    simplify_dp_step(coordinates, tolerance * tolerance)
  end

  @spec simplify(Geo.LineString.t(), number) :: Geo.LineString.t()
  def simplify(%Geo.LineString{} = linestring, tolerance) do
    %Geo.LineString{coordinates: simplify(linestring.coordinates, tolerance)}
  end

  defp simplify_dp_step([], _), do: []
  defp simplify_dp_step([_] = segment, _), do: segment
  defp simplify_dp_step([_, _] = segment, _), do: segment

  defp simplify_dp_step(segment, tolerance_squared) do
    [first | tail] = segment
    {last, middle} = List.pop_at(tail, -1)

    {_, far_value, far_index, far_squared_dist} =
      Enum.reduce(middle, {1, nil, 1, 0}, fn element, {idx, max_val, max_idx, max_dist} ->
        dist = seg_dist(element, first, last)

        if dist >= max_dist do
          {idx + 1, element, idx, dist}
        else
          {idx + 1, max_val, max_idx, max_dist}
        end
      end)

    if far_squared_dist > tolerance_squared do
      {pre_split, post_split} = Enum.split(segment, far_index + 1)
      front = simplify_dp_step(pre_split, tolerance_squared)
      [_ | back] = simplify_dp_step([far_value | post_split], tolerance_squared)

      front ++ back
    else
      [first, last]
    end
  end

  defp seg_dist({px, py, _}, {ax, ay, _}, {bx, by, _}), do: seg_dist({px, py}, {ax, ay}, {bx, by})
  defp seg_dist(p, a, b), do: Distance.segment_distance_squared(p, a, b)
end
