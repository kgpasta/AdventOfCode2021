defmodule Chiton do
  @full_factor 5
  def get_neighbors(grid, {x, y}) do
    Enum.map([{0, 1}, {1, 0}, {0, -1}, {-1, 0}], fn {diff_x, diff_y} ->
      {x + diff_x, y + diff_y}
    end)
    |> Enum.filter(fn val -> Map.has_key?(grid, val) end)
  end

  def get_coords() do
    PriorityQueue.new() |> PriorityQueue.put({0, 0}, 0)
  end

  def loop_paths(grid, open, distances, visited, target) do
    if PriorityQueue.size(open) > 0 do
      {new_open, new_distances, new_visited} =
        search_paths(grid, open, distances, visited, target)

      loop_paths(grid, new_open, new_distances, new_visited, target)
    else
      {distances, visited}
    end
  end

  def get_dist(point, distances) do
    Map.get(distances, point, 10_000_000)
  end

  def get_min_dist(open_set) do
    PriorityQueue.min(open_set)
  end

  def search_paths(grid, open, distances, visited, target) do
    {{starting, _}, new_open} = PriorityQueue.pop(open)

    if starting == target do
      {PriorityQueue.new(), distances, visited}
    else
      neighbors =
        get_neighbors(grid, starting) |> Enum.filter(fn x -> not Enum.member?(visited, x) end)

      Enum.reduce(neighbors, {new_open, distances, visited}, fn x,
                                                                {acc_open, acc_distance,
                                                                 acc_visited} ->
        new_dist = grid[x] + get_dist(starting, acc_distance)

        if new_dist < get_dist(x, acc_distance) do
          {PriorityQueue.put(acc_open, x, new_dist), Map.put(acc_distance, x, new_dist),
           Map.put(acc_visited, x, starting)}
        else
          {acc_open, acc_distance, acc_visited}
        end
      end)
    end
  end

  def get_full_max({max_x, max_y}) do
    {(max_x + 1) * @full_factor - 1, (max_y + 1) * @full_factor - 1}
  end

  def create_full_input(grid, {max_x, max_y}) do
    grids =
      Enum.reduce(0..8, %{}, fn offset, acc ->
        new_grid =
          Enum.map(grid, fn {key, val} ->
            new_val = val + offset
            {key, if(new_val > 9, do: new_val - 9, else: new_val)}
          end)
          |> Map.new()

        Map.put(acc, offset, new_grid)
      end)

    coords =
      Enum.flat_map(0..4, fn x ->
        expanded = List.duplicate(x, 5)
        Enum.zip([expanded, 0..4])
      end)

    Enum.reduce(coords, %{}, fn {x_offset, y_offset}, acc ->
      offset = x_offset + y_offset

      updated_grid =
        Enum.map(grids[offset], fn {{k_x, k_y}, v} ->
          {{x_offset * (max_x + 1) + k_x, y_offset * (max_y + 1) + k_y}, v}
        end)
        |> Map.new()

      Map.merge(acc, updated_grid)
    end)
  end

  def solve() do
    file_input =
      File.read!("puzzles/puzzle15.txt")
      |> String.trim()
      |> String.split("\n")

    max = {(hd(file_input) |> String.length()) - 1, Enum.count(file_input) - 1}

    input =
      file_input
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

    {distances, _visited} =
      Chiton.loop_paths(input, Chiton.get_coords(), %{{0, 0} => 0}, %{{0, 0} => {0, 0}}, max)

    risk_level = distances[max]
    IO.puts("Part1: #{inspect(risk_level)} risk level")

    full_input = Chiton.create_full_input(input, max)
    full_max = Chiton.get_full_max(max)

    {distances_full, _} =
      Chiton.loop_paths(
        full_input,
        Chiton.get_coords(),
        %{{0, 0} => 0},
        %{{0, 0} => {0, 0}},
        full_max
      )

    risk_level_full = distances_full[full_max]
    IO.puts("Part2: #{inspect(risk_level_full)} risk level")
  end
end
