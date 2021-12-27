input =
  File.read!("puzzle10.txt")
  |> String.trim()
  |> String.split("\n")

defmodule SyntaxParser do
  @openers ["(", "[", "{", "<"]
  @closers [")", "]", "}", ">"]
  @pairs Enum.zip(@openers, @closers)

  def is_opener(letter) do
    Enum.member?(@openers, letter)
  end

  def is_closer(letter) do
    Enum.member?(@closers, letter)
  end

  def is_pair(letter_one, letter_two) do
    Enum.find(@pairs, fn x -> elem(x, 0) == letter_one end) |> elem(1) == letter_two
  end

  def parse_line(line) do
    String.codepoints(line)
    |> Enum.reduce_while({:ok, []}, fn x, {_, acc} ->
      if is_opener(x) do
        {:cont, {:ok, List.insert_at(acc, 0, x)}}
      else
        if is_pair(hd(acc), x), do: {:cont, {:ok, tl(acc)}}, else: {:halt, {:error, hd(acc), x}}
      end
    end)
  end

  def is_corrupted(parsed_line) do
    elem(parsed_line, 0) == :error
  end

  def find_corrupted_lines(lines) do
    Enum.map(lines, fn x -> parse_line(x) end) |> Enum.filter(fn x -> is_corrupted(x) end)
  end

  def score_corrupted(lines) do
    Enum.map(lines, fn {_err, _expected, actual} ->
      case actual do
        ")" -> 3
        "]" -> 57
        "}" -> 1197
        ">" -> 25137
      end
    end)
    |> Enum.sum()
  end

  def find_incomplete_lines(lines) do
    Enum.filter(lines, fn x -> not is_corrupted(parse_line(x)) end)
  end

  def complete_line(line) do
    String.codepoints(line)
    |> Enum.reduce([], fn x, acc ->
      if is_opener(x) do
        List.insert_at(acc, 0, x)
      else
        tl(acc)
      end
    end)
    |> Enum.map(fn x ->
      Enum.find(@pairs, fn y -> elem(y, 0) == x end)
      |> elem(1)
    end)
  end

  def score_line(line) do
    Enum.reduce(line, 0, fn x, acc ->
      val =
        case x do
          ")" -> 1
          "]" -> 2
          "}" -> 3
          ">" -> 4
        end

      acc * 5 + val
    end)
  end
end

corrupted_line_score = SyntaxParser.find_corrupted_lines(input) |> SyntaxParser.score_corrupted()
IO.puts("Part1: #{corrupted_line_score} error score")

sorted_scores =
  SyntaxParser.find_incomplete_lines(input)
  |> Enum.map(fn x -> SyntaxParser.complete_line(x) |> SyntaxParser.score_line() end)
  |> Enum.sort()
middle_score = Enum.at(sorted_scores, floor(Enum.count(sorted_scores) / 2))
IO.puts("Part2: #{middle_score} middle score")
