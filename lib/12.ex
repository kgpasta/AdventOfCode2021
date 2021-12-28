defmodule Caves do
  def create_graph(lines) do
    Enum.reduce(lines, %{}, fn {point1, point2}, acc ->
      Map.merge(
        acc,
        Map.new([{point1, MapSet.new([point2])}, {point2, MapSet.new([point1])}]),
        fn _k, v1, v2 ->
          MapSet.union(v1, v2)
        end
      )
    end)
  end

  def is_big_cave(str) do
    str == String.upcase(str)
  end

  def parse_paths(lines, small_cave_visits) do
    create_graph(lines)
    |> find_paths(["start"], [], "start", small_cave_visits)
  end

  def can_visit(point, path, small_cave_visits) do
    if is_big_cave(point) do
      true
    else
      if point == "start" do
        false
      else
        frequencies = Enum.filter(path, fn x -> not is_big_cave(x) end) |> Enum.frequencies()
        num_times = Map.get(frequencies, point, 0)

        if Enum.any?(frequencies, fn {_key, value} -> value == small_cave_visits end) do
          num_times == 0
        else
          num_times < small_cave_visits
        end
      end
    end
  end

  def find_paths(graph, root_path, paths, point, small_cave_visits) do
    Enum.filter(graph[point], fn x -> can_visit(x, root_path, small_cave_visits) end)
    |> Enum.reduce(paths, fn x, acc ->
      if x == "end" do
        acc ++ [root_path ++ [x]]
      else
        find_paths(graph, root_path ++ [x], acc, x, small_cave_visits)
      end
    end)
  end

  def solve() do
    input =
      File.read!("puzzles/puzzle12.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x -> String.split(x, "-") |> List.to_tuple() end)

    paths = Caves.parse_paths(input, 1)
    IO.puts("Part1: #{Enum.count(paths)} paths")

    two_paths = Caves.parse_paths(input, 2)
    IO.puts("Part2: #{Enum.count(two_paths)} paths")
  end
end
