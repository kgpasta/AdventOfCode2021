lines =
  File.read!("puzzle3.txt")
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(fn x -> String.codepoints(x) |> Enum.map(fn y -> elem(Integer.parse(y), 0) end) end)

defmodule Bits do
  def get_most_common_bits(list, is_greater, is_less) do
    starting_count = Enum.count(hd(list))
    starting = List.duplicate(0, starting_count) |> List.to_tuple()
    size = Enum.count(list)

    sum =
      Enum.reduce(list, starting, fn x, acc ->
        Enum.with_index(x)
        |> Enum.map(fn {item, index} -> item + elem(acc, index) end)
        |> List.to_tuple()
      end)
      |> Tuple.to_list()

    Enum.map(sum, fn x -> if size - x > size / 2, do: is_greater, else: is_less end)
  end

  def binary_list_to_integer(list) do
    Enum.join(list, "")
    |> Integer.parse(2)
    |> elem(0)
  end

  def filter_most_common_bits(list, index, func) do
    starting_count = Enum.count(hd(list))

    if Enum.count(list) == 1 do
      hd(list)
    else
      most_common = func.(Enum.map(list, fn x -> Enum.slice(x, index..starting_count) end))

      filtered_trailed_list = Enum.filter(list, fn x -> Enum.at(x, index) == hd(most_common) end)

      filter_most_common_bits(filtered_trailed_list, index + 1, func)
    end
  end
end

gamma_bits = Bits.get_most_common_bits(lines, 0, 1)
gamma = Bits.binary_list_to_integer(gamma_bits)

epsilon_bits = Bits.get_most_common_bits(lines, 1, 0)
epsilon = Bits.binary_list_to_integer(epsilon_bits)

IO.puts("Part1: #{gamma} gamma, #{epsilon} epsilon, #{gamma * epsilon} multiplied")

oxygen_bits =
  Bits.filter_most_common_bits(lines, 0, fn x -> Bits.get_most_common_bits(x, 0, 1) end)

oxygen = Bits.binary_list_to_integer(oxygen_bits)

scrubber_bits =
  Bits.filter_most_common_bits(lines, 0, fn x -> Bits.get_most_common_bits(x, 1, 0) end)

scrubber = Bits.binary_list_to_integer(scrubber_bits)

IO.puts("Part1: #{oxygen} oxygen, #{scrubber} co2 scrubber, #{oxygen * scrubber} multiplied")
