defmodule Simplify do
  @moduledoc """
  Implementation of the [Ramer–Douglas–Peucker](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm)
  algorithm for reducing the number of points used to represent a curve.

  The `Simplify` module contains a function `simplify` that accepts a List of
  coordinates, each coordinate being a tuple `{x, y}`, and a tolerance.  The
  function reduces the number of points by removing points that are less than
  the tolerance away from the simplified curve.

  ```elixir
  points = [{0, 0}, {0.05, 0.05}, {-0.05, 0.5}, {0, 1}, {0.05, 1.1}, {1, 1}, {0.5, 0.5}, {0, 0.0001}]

  Simplify.simplify(points, 0.1) # => [{0, 0}, {0.05, 1.1}, {1, 1}, {0, 0.0001}]
  ```

  The method will also take a `Geo.LineString` struct as created by the conversion
  functions in the Geo project (https://github.com/bryanjos/geo).  This allows
  for easy import of GeoJSON or WKT/WKB formats.  This version of the function
  returns a `Geo.LineString` of the simplified curve.

  ```elixir
  "{\"type\":\"LineString\":\"coordinates\":[[0,0],[0.05,0.05],[-0.05,0.5],[0,1],[0.05,1.1],[1,1],[0.5,0.5],[0,0.0001]]"
  |> Jason.decode!
  |> Geo.JSON.decode
  |> Simplify.simplify(0.1)
  |> Geo.JSON.encode
  |> Jason.encode! # => "{\"coordinates\":[[0,0],[0.05,1.1],[1,1],[0,0.0001]],\"type\":\"LineString\"}"
  ```
  """
  @type point :: {number, number}

  @spec simplify(list(point), number) :: list(point)
  def simplify(coordinates, tolerance) when is_list(coordinates) do
    simplify_dp_step(coordinates, tolerance * tolerance)
  end

  @spec simplify(Geo.LineString.t(), number) :: Geo.LineString.t()
  def simplify(%Geo.LineString{} = linestring, tolerance) do
    %Geo.LineString{
      coordinates: simplify(linestring.coordinates, tolerance),
      srid: linestring.srid
    }
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
