line =
  File.read!("puzzle7.txt")
  |> String.trim()
  |> String.split("\n")
  |> hd()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

defmodule CrabSubmarines do
  def organize_list_into_buckets(list) do
    Enum.reduce(list, %{}, fn x, acc -> Map.update(acc, x, 1, fn x -> x + 1 end) end)
  end

  def get_median(list) do
    midpoint =
      (Enum.count(list) / 2)
      |> Float.floor()
      |> round

    {l1, l2} =
      Enum.sort(list)
      |> Enum.split(midpoint)

    case Enum.count(l2) > Enum.count(l1) do
      true ->
        hd(l2) |> round

      false ->
        m1 = hd(l2)
        m2 = Enum.reverse(l1) |> hd()
        ((m1 + m2) / 2) |> round
    end
  end

  def distance_from_point(point, list) do
    Enum.map(list, fn x -> abs(point - x) end) |> Enum.sum()
  end

  def get_smallest_distance(list) do
    Enum.min(list)..Enum.max(list)
    |> Enum.with_index()
    |> Enum.map(fn {item, index} -> {exp_distance_from_point(item, list), index} end)
    |> Enum.min_by(fn {item, _index} -> item end)
  end

  def exp_distance(n) do
    if n == 0 do
      0
    else
      n + exp_distance(n - 1)
    end
  end

  def exp_distance_from_point(point, list) do
    Enum.map(list, fn x -> abs(point - x) |> exp_distance() end) |> Enum.sum()
  end
end

distance = CrabSubmarines.get_median(line) |> CrabSubmarines.distance_from_point(line)
IO.puts("Part1: #{distance} fuel expended")

{distance_two, _position} = CrabSubmarines.get_smallest_distance(line)

IO.puts("Part2: #{distance_two} fuel expended")
