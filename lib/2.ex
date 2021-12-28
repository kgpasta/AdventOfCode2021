defmodule Depth do
  def solve() do
    list =
      File.read!("puzzles/puzzle2.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x -> String.split(x, " ") end)
      |> Enum.map(fn x -> {hd(x), elem(Integer.parse(List.last(x)), 0)} end)

    {distance, depth} =
      Enum.reduce(list, {0, 0}, fn x, acc ->
        case elem(x, 0) do
          "forward" -> {elem(x, 1) + elem(acc, 0), elem(acc, 1)}
          "up" -> {elem(acc, 0), elem(acc, 1) - elem(x, 1)}
          "down" -> {elem(acc, 0), elem(acc, 1) + elem(x, 1)}
        end
      end)

    IO.puts(
      "Part1: #{distance} distance, #{depth} depth, and #{distance * depth} multiplied depth"
    )

    {distance_two, depth_two, _aim} =
      Enum.reduce(list, {0, 0, 0}, fn x, acc ->
        case elem(x, 0) do
          "forward" ->
            {elem(x, 1) + elem(acc, 0), elem(acc, 1) + elem(x, 1) * elem(acc, 2), elem(acc, 2)}

          "up" ->
            {elem(acc, 0), elem(acc, 1), elem(acc, 2) - elem(x, 1)}

          "down" ->
            {elem(acc, 0), elem(acc, 1), elem(acc, 2) + elem(x, 1)}
        end
      end)

    IO.puts(
      "Part2: #{distance_two} distance, #{depth_two} depth, and #{distance_two * depth_two} multiplied depth"
    )
  end
end
