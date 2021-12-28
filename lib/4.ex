defmodule Bingo do
  def map_strings_to_integers(list) do
    Enum.filter(list, fn x -> String.trim(x) != "" end)
    |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)
  end

  def is_bingo(board_scorer) do
    is_row_bingo(board_scorer) or is_column_bingo(board_scorer)
  end

  def is_row_bingo(board_scorer) do
    Enum.any?(board_scorer, fn x -> Enum.all?(x, fn y -> y == 1 end) end)
  end

  def is_column_bingo(board_scorer) do
    column_scores =
      Enum.reduce(board_scorer, [0, 0, 0, 0, 0], fn x, acc ->
        Enum.with_index(x)
        |> Enum.map(fn {item, index} -> item + Enum.at(acc, index) end)
      end)

    Enum.any?(column_scores, fn x -> x == 5 end)
  end

  def score_board(number, board, scorer) do
    Enum.zip(board, scorer)
    |> Enum.map(fn {board_row, score_row} ->
      Enum.zip(board_row, score_row)
      |> Enum.map(fn {board_number, score_number} ->
        if board_number == number, do: 1, else: score_number
      end)
    end)
  end

  def score_boards(number, boards, scorers) do
    Enum.with_index(scorers)
    |> Enum.map(fn {item, index} -> score_board(number, Enum.at(boards, index), item) end)
  end

  def play_bingo(numbers, boards, scorers) do
    number = hd(numbers)
    new_scores = score_boards(number, boards, scorers)
    result = Enum.zip(boards, new_scores) |> Enum.find(fn x -> is_bingo(elem(x, 1)) end)

    if result do
      {number, elem(result, 0), elem(result, 1)}
    else
      play_bingo(tl(numbers), boards, new_scores)
    end
  end

  def play_bingo_till_end(numbers, boards, scorers) do
    number = hd(numbers)
    new_scores = score_boards(number, boards, scorers)

    {result, remaining} =
      Enum.zip(boards, new_scores) |> Enum.split_with(fn x -> is_bingo(elem(x, 1)) end)

    if Enum.count(result) == 1 and Enum.count(boards) == 1 do
      {number, elem(hd(result), 0), elem(hd(result), 1)}
    else
      play_bingo_till_end(
        tl(numbers),
        Enum.map(remaining, fn x -> elem(x, 0) end),
        Enum.map(remaining, fn x -> elem(x, 1) end)
      )
    end
  end

  def calculate_unmarked_sum(board, scorer) do
    Enum.zip(board, scorer)
    |> Enum.map(fn {board_row, score_row} ->
      Enum.zip(board_row, score_row)
      |> Enum.reduce(0, fn {board_number, score_number}, acc ->
        if score_number == 0, do: acc + board_number, else: acc
      end)
    end)
    |> Enum.sum()
  end

  def solve() do
    lines =
      File.read!("puzzles/puzzle4.txt")
      |> String.trim()
      |> String.split("\n")

    numbers_drawn = hd(lines) |> String.split(",") |> Bingo.map_strings_to_integers()

    boards =
      tl(lines)
      |> Enum.filter(fn x -> String.trim(x) != "" end)
      |> Enum.map(fn x ->
        String.trim(x) |> String.split(" ") |> Bingo.map_strings_to_integers()
      end)
      |> Enum.chunk_every(5)

    board_scorers = List.duplicate(List.duplicate([0, 0, 0, 0, 0], 5), Enum.count(boards))

    {number, winning_board, winning_scorer} =
      Bingo.play_bingo(numbers_drawn, boards, board_scorers)

    unmarked_sum = Bingo.calculate_unmarked_sum(winning_board, winning_scorer)

    IO.puts(
      "Part1: #{number} winning number, #{unmarked_sum} unmarked sum, #{number * unmarked_sum} score"
    )

    {last_number, last_winning_board, last_winning_scorer} =
      Bingo.play_bingo_till_end(numbers_drawn, boards, board_scorers)

    last_unmarked_sum = Bingo.calculate_unmarked_sum(last_winning_board, last_winning_scorer)

    IO.puts(
      "#{last_number} last winning number, #{last_unmarked_sum} last unmarked sum, #{last_number * last_unmarked_sum} last score"
    )
  end
end
