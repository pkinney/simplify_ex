# Simplify

[![Build Status](https://travis-ci.org/pkinney/simplify_ex.svg?branch=master)](https://travis-ci.org/pkinney/simplify_ex)
[![Hex.pm](https://img.shields.io/hexpm/v/simplify.svg)](https://hex.pm/packages/simplify)

Implementation of the [Ramer–Douglas–Peucker](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm)
algorithm for reducing the number of points used to represent a curve.

![Simplifying a piecewise linear curve with the Douglas–Peucker algorithm](https://upload.wikimedia.org/wikipedia/commons/3/30/Douglas-Peucker_animated.gif)

## Installation

```elixir
defp deps do
  [{:simplify, "~> 0.2.0"}]
end
```

## Usage

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
