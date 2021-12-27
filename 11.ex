input =
  File.read!("puzzle11.txt")
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

defmodule OctopusFlash do
  @flash_point 10
  def get_neighbors(grid, {x, y}) do
    Enum.map([{0, 1}, {1, 0}, {-1, 0}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}], fn {diff_x,
                                                                                         diff_y} ->
      {x + diff_x, y + diff_y}
    end)
    |> Enum.filter(fn val -> Map.has_key?(grid, val) end)
  end

  def calculate_steps(grid, flashes, steps_taken, total_steps) do
    if steps_taken == total_steps do
      {grid, flashes}
    else
      {new_grid, new_flashes} =
        Enum.map(grid, fn {key, val} -> {key, val + 1} end)
        |> Map.new()
        |> calculate_step(0)
        |> reset_grid()

      calculate_steps(new_grid, new_flashes + flashes, steps_taken + 1, total_steps)
    end
  end

  def find_next_point(grid) do
    Enum.find(grid, {nil}, fn {_key, val} -> val == @flash_point end) |> elem(0)
  end

  def calculate_step(grid, flashes) do
    next_point = find_next_point(grid)

    if next_point == nil do
      {grid, flashes}
    else
      if grid[next_point] == @flash_point do
        get_neighbors(grid, next_point)
        |> Enum.filter(fn x -> grid[x] != @flash_point end)
        |> Enum.reduce(grid, fn x, acc ->
          Map.put(acc, x, acc[x] + 1)
        end)
        |> Map.put(next_point, grid[next_point] + 1)
        |> calculate_step(flashes + 1)
      else
        calculate_step(grid, flashes)
      end
    end
  end

  def reset_grid({grid, flashes}) do
    {Enum.map(grid, fn {pt, val} -> if val >= @flash_point, do: {pt, 0}, else: {pt, val} end)
     |> Map.new(), flashes}
  end

  def is_all_flashing(grid) do
    Enum.all?(grid, fn {_key, val} -> val >= @flash_point end)
  end

  def get_first_simultaneous(grid, steps_taken) do
    {new_grid, new_flashes} =
      Enum.map(grid, fn {key, val} -> {key, val + 1} end)
      |> Map.new()
      |> calculate_step(0)

    if is_all_flashing(new_grid) do
      steps_taken + 1
    else
      reset_g = reset_grid({new_grid, new_flashes}) |> elem(0)
      get_first_simultaneous(reset_g, steps_taken + 1)
    end
  end
end

{_new_grid, flashes} = OctopusFlash.calculate_steps(input, 0, 0, 100)
IO.puts("Part1: #{flashes} flashes")

steps = OctopusFlash.get_first_simultaneous(input, 0)
IO.puts("Part2: #{steps} steps")
