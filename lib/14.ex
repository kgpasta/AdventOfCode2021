defmodule Polymer do
  def create_chunks(template) do
    template
    |> String.codepoints()
    |> Enum.chunk_every(2, 1)
    |> Enum.map(fn x -> {Enum.join(x, ""), 1} end)
    |> Map.new()
  end

  def perform_step(template_map, pairs) do
    Enum.reduce(template_map, %{}, fn {key, val}, acc ->
      if Map.has_key?(pairs, key) do
        first = String.at(key, 0) <> pairs[key]
        last = pairs[key] <> String.at(key, 1)

        Map.update(acc, first, val, fn x -> x + val end)
        |> Map.update(last, val, fn x -> x + val end)
      else
        acc
      end
    end)
  end

  def perform_steps(template_map, pairs, steps, total_steps) do
    if steps == total_steps do
      template_map
    else
      new_template = perform_step(template_map, pairs)
      perform_steps(new_template, pairs, steps + 1, total_steps)
    end
  end

  def get_score(template_map) do
    sorted_frequencies =
      Enum.reduce(template_map, %{}, fn {k, val}, acc ->
        first = String.at(k, 0)
        second = String.at(k, 1)

        Map.update(acc, first, val, fn x -> x + val end)
        |> Map.update(second, val, fn x -> x + val end)
      end)
      |> Enum.map(fn {_k, val} -> val / 2 end)
      |> Enum.sort()

    ceil(Enum.at(sorted_frequencies, -1)) - ceil(hd(sorted_frequencies))
  end

  def solve() do
    input =
      File.read!("puzzles/puzzle14.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.split_while(fn x -> String.length(x) > 0 end)

    template_input = elem(input, 0) |> hd() |> Polymer.create_chunks()

    pair_input =
      elem(input, 1)
      |> tl()
      |> Enum.map(fn x -> String.split(x, " -> ") |> List.to_tuple() end)
      |> Map.new()

    step = Polymer.perform_steps(template_input, pair_input, 0, 10)
    score = Polymer.get_score(step)

    IO.puts("Part1: #{inspect(score)}")

    step = Polymer.perform_steps(template_input, pair_input, 0, 40)
    score = Polymer.get_score(step)

    IO.puts("Part2: #{inspect(score)}")
  end
end
