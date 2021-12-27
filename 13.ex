input =
  File.read!("puzzle13.txt")
  |> String.trim()
  |> String.split("\n")
  |> Enum.split_while(fn x -> String.length(x) > 0 end)

dots_input =
  Enum.map(elem(input, 0), fn x ->
    String.split(x, ",")
    |> Enum.map(fn y -> Integer.parse(y, 10) |> elem(0) end)
    |> List.to_tuple()
  end)

folds_input =
  elem(input, 1)
  |> tl()
  |> Enum.map(fn x ->
    String.replace_prefix(x, "fold along ", "")
    |> String.split("=")
    |> List.update_at(1, fn y -> Integer.parse(y, 10) |> elem(0) end)
    |> List.to_tuple()
  end)

defmodule Origami do
  def fold_paper(dots, {direction, line}) do
    Enum.map(dots, fn {x, y} ->
      value = if direction == "x", do: x, else: y
      flipped_value = line - (value - line)
      flipped = if direction == "x", do: {flipped_value, y}, else: {x, flipped_value}

      if value > line, do: flipped, else: {x, y}
    end)
    |> MapSet.new()
  end

  def folding_paper(dots, folds) do
    Enum.reduce(folds, dots, fn x, acc ->
      fold_paper(acc, x)
    end)
  end

  def visualize(dots) do
    x_dimension = Enum.max_by(dots, fn dot -> elem(dot, 0) end) |> elem(0)
    y_dimension = Enum.max_by(dots, fn dot -> elem(dot, 1) end) |> elem(1)

    0..y_dimension
    |> Enum.map(fn y ->
      0..x_dimension
      |> Enum.map(fn x ->
        if MapSet.member?(dots, {x, y}), do: IO.write("#"), else: IO.write(".")
      end)

      IO.write("\n")
    end)
  end
end

dots_visible = Origami.fold_paper(dots_input, hd(folds_input))
IO.puts("Part1: #{Enum.count(dots_visible)} dots visible")

full_folds = Origami.folding_paper(dots_input, folds_input)
IO.puts("Part2:")
Origami.visualize(full_folds)
