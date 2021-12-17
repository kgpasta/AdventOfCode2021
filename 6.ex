line =
  File.read!("puzzle6.txt")
  |> String.trim()
  |> String.split("\n")
  |> hd()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

defmodule LanternFish do
  @reproduction_days 6
  @starting_days 2

  def organize_list_into_buckets(list) do
    Enum.reduce(list, %{}, fn x, acc -> Map.update(acc, x, 1, fn x -> x + 1 end) end)
  end

  def get_new_offspring_list(buckets, days_left, total_days) do
    new_buckets =
      Enum.map(buckets, fn {key, value} ->
        new_key = if key == 0, do: @reproduction_days, else: key - 1

        new_value =
          if key == 0 or key == 7,
            do: Map.get(buckets, 0, 0) + Map.get(buckets, 7, 0),
            else: value

        {new_key, new_value}
      end)
      |> Enum.filter(fn {_key, value} -> value != nil end)
      |> Map.new()
      |> Map.put(@reproduction_days + @starting_days, Map.get(buckets, 0, 0))

    if days_left == total_days do
      new_buckets
    else
      get_new_offspring_list(new_buckets, days_left + 1, total_days)
    end
  end
end

buckets = LanternFish.organize_list_into_buckets(line)
observation_days = 80
new_list = LanternFish.get_new_offspring_list(buckets, 1, observation_days)

total_sum =
  Enum.map(new_list, fn {_key, val} -> val end) |> Enum.sum()

IO.puts("Part1: #{total_sum} number of lanternfish")

second_observation_days = 256
second_list = LanternFish.get_new_offspring_list(buckets, 1, second_observation_days)

second_sum =
  Enum.map(second_list, fn {_key, val} -> val end) |> Enum.sum()

IO.puts("Part2: #{second_sum} number of lanternfish")
