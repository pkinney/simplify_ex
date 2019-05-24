defmodule SimplifyTest do
  use ExUnit.Case

  doctest Simplify

  test "simplify a straight line" do
    points = [{1, 2}, {2, 4}, {3, 6}]
    simplified = [{1, 2}, {3, 6}]

    assert Simplify.simplify(points, 3) == simplified
  end

  test "simplify a long straight line" do
    points = [{1, 2}, {2, 4.01}, {3, 6}, {5.3, 10}, {8, 15}, {10, 21}]
    simplified = [{1, 2}, {10, 21}]

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
    points = [
      {0, 0},
      {0.05, 0.05},
      {-0.05, 0.5},
      {0, 1},
      {0.05, 1.1},
      {1, 1},
      {0.5, 0.5},
      {0, 0.0001}
    ]

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
      {2, 1}
    ]

    assert Simplify.simplify(points, 0.1) == [{0, 0}, {1, 0}, {2, 1}]
    assert Simplify.simplify(points, 0.009) == [{0, 0}, {0.5, 0.01}, {1, 0}, {2, 1}]
  end

  test "simplify with additional properties" do
    points = [
      {0, 0, "A"},
      {0.01, 0, "B"},
      {0.5, 0.01, "C"},
      {0.7, 0, "D"},
      {1, 0, "E"},
      {1.999, 0.999, "F"},
      {2, 1, "G"}
    ]

    assert Enum.map(Simplify.simplify(points, 0.009), &elem(&1, 2)) == ["A", "C", "E", "G"]
  end

  test "simplify lots of tuples" do
    shape =
      Path.join(["test", "fixtures", "linestring.geo.json"])
      |> File.read!()
      |> Jason.decode!()
      |> Geo.JSON.decode!()

    expected =
      Path.join(["test", "fixtures", "expect.linestring.geo.json"])
      |> File.read!()
      |> Jason.decode!()
      |> Geo.JSON.decode!()

    assert Simplify.simplify(shape, 0.005) == expected
  end

  test "Geo.LineString simplification" do
    simplified =
      "{\"type\":\"LineString\",\"coordinates\":[[0,0],[0.05,0.05],[-0.05,0.5],[0,1],[0.05,1.1],[1,1],[0.5,0.5],[0,0.0001]]}"
      |> Jason.decode!()
      |> Geo.JSON.decode!()
      |> Simplify.simplify(0.1)
      |> Geo.JSON.encode!()
      |> Jason.encode!()

    assert simplified ==
             "{\"coordinates\":[[0,0],[0.05,1.1],[1,1],[0,0.0001]],\"type\":\"LineString\"}"
  end

  test "large ring simplification" do
    ring =
      Path.join(["test", "fixtures", "large_linestring.wkt"])
      |> File.read!()
      |> Geo.WKT.decode!()

    simplified = Simplify.simplify(ring, 100)
    simplified_again = Simplify.simplify(simplified, 100)

    assert length(simplified.coordinates) < length(ring.coordinates)
    assert length(simplified.coordinates) == length(simplified_again.coordinates)
  end
end
