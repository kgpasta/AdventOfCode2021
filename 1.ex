list =
  File.read!("puzzle1.txt")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&String.to_integer/1)


{a, _b} = Enum.reduce(list, {0, 100000}, fn x, acc -> if x > elem(acc, 1), do: {elem(acc, 0) + 1, x}, else: {elem(acc, 0), x} end)
IO.puts("Part1: #{a} increasing items")

{c, _d} = 
  Enum.chunk_every(list, 3, 1, :discard)
  |> Enum.map(fn x -> Enum.sum(x) end)
  |> Enum.reduce({0, 100000}, fn x, acc -> if x > elem(acc, 1), do: {elem(acc, 0) + 1, x}, else: {elem(acc, 0), x} end)

IO.puts("Part2: #{c} increasing windows")

