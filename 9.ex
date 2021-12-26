grid =
  File.read!("puzzle9.txt")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn x ->
    String.codepoints(x) |> Enum.map(fn y -> Integer.parse(y, 10) |> elem(0) end)
  end)
  |> Enum.with_index()
  |> Enum.reduce(%{}, fn {list, y}, acc ->
    Enum.with_index(list)
    |> Enum.map(fn {val, x} -> {{x, y}, val} end)
    |> Map.new()
    |> Map.merge(acc)
  end)

defmodule SmokeBasin do
  def get_adjacent_points({x, y}, grid) do
    Enum.map([{0, 1}, {1, 0}, {-1, 0}, {0, -1}], fn {diff_x, diff_y} ->
      {x + diff_x, y + diff_y}
    end)
    |> Enum.filter(fn val -> Map.has_key?(grid, val) end)
  end

  def get_next_low_point(grid, explored, {x, y}) do
    adjacent_points = get_adjacent_points({x, y}, grid)
    adjacent_values = Enum.map(adjacent_points, fn point -> grid[point] end)
    current_value = grid[{x, y}]
    min_value = Enum.min(adjacent_values ++ [current_value])

    new_explored = Map.put(explored, {x, y}, min_value)

    if min_value == current_value and
         Enum.filter(adjacent_values ++ [current_value], fn val -> val == min_value end)
         |> Enum.count() == 1 do
      {new_explored, [{x, y}]}
    else
      Enum.reduce(adjacent_points, {new_explored, []}, fn point, {tree_explored, low_points} ->
        if Map.has_key?(tree_explored, point) do
          {tree_explored, low_points}
        else
          {branch_explored, branch_points} = get_next_low_point(grid, tree_explored, point)
          {Map.merge(tree_explored, branch_explored), low_points ++ branch_points}
        end
      end)
    end
  end

  def get_low_points(grid) do
    Enum.reduce(grid, {%{}, []}, fn {point, _val}, {explored, low_list} ->
      if Map.has_key?(explored, point) do
        {explored, low_list}
      else
        {new_explored, new_lows} = get_next_low_point(grid, explored, point)
        {new_explored, low_list ++ new_lows}
      end
    end)
  end

  def get_risk_levels(grid, points) do
    Enum.map(points, fn x -> grid[x] + 1 end)
  end

  def find_basins(grid, low_points) do
    Enum.map(low_points, fn x ->
      find_basin(grid, x, MapSet.new())
    end)
  end

  def find_basin(grid, point, basin_points) do
    if grid[point] == 9 do
      basin_points
    else
      adjacent_points =
        get_adjacent_points(point, grid)
        |> Enum.filter(fn pt ->
          not MapSet.member?(basin_points, pt)
        end)

      new_basin_points =
        Enum.reduce(adjacent_points, basin_points, fn x, acc ->
          if grid[x] != 9, do: MapSet.put(acc, x), else: acc
        end)

      Enum.reduce(adjacent_points, new_basin_points, fn x, acc ->
        MapSet.union(acc, find_basin(grid, x, acc))
       end)
    end
  end

  def get_top_3(basins) do
    Enum.sort(basins, fn x, y -> Enum.count(x) > Enum.count(y) end)
    |> Enum.slice(0, 3)
    |> Enum.map(fn x -> Enum.count(x) end)
  end
end

{_explored, low_points} = SmokeBasin.get_low_points(grid)
risk_levels = SmokeBasin.get_risk_levels(grid, low_points)
IO.puts("Part1: #{Enum.sum(risk_levels)} risk levels")

basins = SmokeBasin.find_basins(grid, low_points)
top_3 = SmokeBasin.get_top_3(basins)
IO.puts("Part2: #{Enum.product(top_3)} basin sizes")
