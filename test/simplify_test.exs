defmodule SimplifyTest do
  use ExUnit.Case

  doctest Simplify

  test "simplify a straight line" do
    points = [{1,2}, {2,4}, {3,6}]
    simplified = [{1,2}, {3,6}]

    assert Simplify.simplify(points, 3) == simplified
  end

  test "simplify a long straight line" do
    points = [{1,2}, {2,4.01}, {3,6}, {5.3, 10}, {8, 15}, {10, 21}]
    simplified = [{1,2}, {10, 21}]

    assert Simplify.simplify(points, 3) == simplified
  end

  test "simplify a triangle when the tolerance is low enough" do
    points = [{0, 0}, {1, 1}, {2, 0}]
    simplified = [{0, 0}, {2, 0}]

    assert Simplify.simplify(points, 1.1) == simplified
  end

  test "simplify a triangle when the tolerance is not low enough" do
    points = [{0, 0}, {1, 1}, {2, 0}]
    simplified = [{0, 0}, {1, 1}, {2, 0}]

    assert Simplify.simplify(points, 0.9) == simplified
  end

  test "simplify linesting with close first and last points" do
    points = [{0, 0}, {0.05, 0.05}, {-0.05, 0.5}, {0, 1}, {0.05, 1.1}, {1, 1}, {0.5, 0.5}, {0, 0.0001}]
    simplified = [{0, 0}, {0.05, 1.1}, {1, 1}, {0, 0.0001}]

    assert Simplify.simplify(points, 0.1) == simplified
  end

  test "simplify linesting according to tolerance" do
    points = [
      {0, 0},
      {0.01, 0},
      {0.5, 0.01},
      {0.7, 0},
      {1, 0},
      {1.999, 0.999},
      {2,1}
    ]

    assert Simplify.simplify(points, 0.1) == [ {0, 0}, {1, 0}, {2, 1} ]
    assert Simplify.simplify(points, 0.009) == [ {0, 0}, {0.5, 0.01}, {1, 0}, {2, 1} ]
  end

  test "simplify lots of tuples" do
    shape =
      Path.join([ "test", "fixtures", "linestring.geo.json" ])
      |> File.read!
      |> Poison.decode!
      |> Geo.JSON.decode

    expected =
      Path.join([ "test", "fixtures", "expect.linestring.geo.json" ])
      |> File.read!
      |> Poison.decode!
      |> Geo.JSON.decode

    assert Simplify.simplify(shape, 0.005) == expected
  end

  test "Geo.LineString simplification" do
    simplified =
      "{\"type\":\"LineString\",\"coordinates\":[[0,0],[0.05,0.05],[-0.05,0.5],[0,1],[0.05,1.1],[1,1],[0.5,0.5],[0,0.0001]]}"
      |> Poison.decode!
      |> Geo.JSON.decode
      |> Simplify.simplify(0.1)
      |> Geo.JSON.encode
      |> Poison.encode!

    assert simplified == "{\"type\":\"LineString\",\"coordinates\":[[0,0],[0.05,1.1],[1,1],[0,0.0001]]}"
  end
end
