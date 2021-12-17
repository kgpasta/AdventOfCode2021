lines =
  File.read!("puzzle5.txt")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn x ->
    String.split(x, " -> ")
    |> Enum.map(fn y ->
      String.split(y, ",") |> Enum.map(fn z -> elem(Integer.parse(z), 0) end) |> List.to_tuple()
    end)
  end)

defmodule Vents do
  def get_points_in_line(points, start_point, end_point) do
    new_points = points ++ [start_point]
    {current_x, current_y} = start_point

    new_x =
      current_x +
        case current_x - elem(end_point, 0) do
          x when x > 0 -> -1
          x when x == 0 -> 0
          x when x < 0 -> 1
        end

    new_y =
      current_y +
        case current_y - elem(end_point, 1) do
          x when x > 0 -> -1
          x when x == 0 -> 0
          x when x < 0 -> 1
        end

    if new_x == current_x and new_y == current_y do
      new_points
    else
      get_points_in_line(new_points, {new_x, new_y}, end_point)
    end
  end

  def is_horizontal_or_vertical(start_point, end_point) do
    {start_x, start_y} = start_point
    {end_x, end_y} = end_point
    start_x == end_x or start_y == end_y
  end
end

point_map =
  Enum.filter(lines, fn [start_point, end_point] ->
    Vents.is_horizontal_or_vertical(start_point, end_point)
  end)
  |> Enum.reduce(%{}, fn [start_point, end_point], acc ->
    Vents.get_points_in_line([], start_point, end_point)
    |> Enum.into(%{}, fn x -> {x, 1} end)
    |> Map.merge(acc, fn _k, x, y -> x + y end)
  end)

vent_overlap =
  Enum.filter(point_map, fn {_point, frequency} -> frequency > 1 end)
  |> Enum.count()

IO.puts("Part1: #{vent_overlap} overlapping points")

diagonal_point_map =
  Enum.reduce(lines, %{}, fn [start_point, end_point], acc ->
    Vents.get_points_in_line([], start_point, end_point)
    |> Enum.into(%{}, fn x -> {x, 1} end)
    |> Map.merge(acc, fn _k, x, y -> x + y end)
  end)

diagonal_vent_overlap =
  Enum.filter(diagonal_point_map, fn {_point, frequency} -> frequency > 1 end)
  |> Enum.count()

IO.puts("Part2: #{diagonal_vent_overlap} overlapping points")
