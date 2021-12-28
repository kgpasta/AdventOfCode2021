defmodule SevenSegment do
  @unique_segment_size_to_val %{2 => 1, 3 => 7, 4 => 4, 7 => 8}
  @number_to_segments %{
    0 => "abcefg",
    1 => "cf",
    2 => "acdeg",
    3 => "acdfg",
    4 => "bcdf",
    5 => "abdfg",
    6 => "abdefg",
    7 => "acf",
    8 => "abcdefg",
    9 => "abcdfg"
  }

  def get_unique_number_frequency(list) when is_list(list) do
    Enum.reduce(list, 0, fn x, acc ->
      get_unique_number_frequency(x) + acc
    end)
  end

  def get_unique_number_frequency(tuple) when is_tuple(tuple) do
    elem(tuple, 1)
    |> Enum.count(fn x -> Map.has_key?(@unique_segment_size_to_val, String.length(x)) end)
  end

  def string_to_map_set(word) do
    String.codepoints(word) |> MapSet.new()
  end

  def get_intersecting_letters(word1, word2) when is_binary(word1) and is_binary(word2) do
    map_set_1 = string_to_map_set(word1)
    map_set_2 = string_to_map_set(word2)

    get_intersecting_letters(map_set_1, map_set_2)
  end

  def get_intersecting_letters(map_set_1, map_set_2) do
    {MapSet.difference(map_set_1, map_set_2), MapSet.intersection(map_set_1, map_set_2),
     MapSet.difference(map_set_2, map_set_1)}
  end

  def get_unique_segments(line) do
    segment_map =
      Enum.reduce(line, %{}, fn x, acc ->
        if Map.has_key?(@unique_segment_size_to_val, String.length(x)) do
          Map.put(acc, @unique_segment_size_to_val[String.length(x)], x)
        else
          acc
        end
      end)

    {line, segment_map}
  end

  def is_same_letters(word1, word2) do
    MapSet.equal?(string_to_map_set(word1), string_to_map_set(word2))
  end

  def get_deduped_list_of_letters(line, size) do
    Enum.filter(line, fn x -> String.length(x) == size end)
    |> Enum.map(fn x -> string_to_map_set(x) end)
    |> Enum.uniq()
  end

  def find_unique_letter(options, word) do
    Enum.find_value(options, fn x ->
      {left, _union, _right} = get_intersecting_letters(string_to_map_set(word), x)
      if Enum.count(left) == 1, do: left, else: nil
    end)
  end

  def to_letter(map_set) do
    Enum.fetch(map_set, 0) |> elem(1)
  end

  def discover_letters({line, segment_map}) do
    a = get_intersecting_letters(segment_map[7], segment_map[1]) |> elem(0)

    e_g =
      get_intersecting_letters(segment_map[8], segment_map[4])
      |> elem(0)
      |> MapSet.difference(a)

    b_d =
      get_intersecting_letters(segment_map[4], segment_map[1])
      |> elem(0)

    two =
      Enum.find(line, fn x ->
        String.length(x) == 5 and MapSet.subset?(e_g, string_to_map_set(x))
      end)

    e = get_deduped_list_of_letters(line, 5) |> find_unique_letter(two)
    g = MapSet.difference(e_g, e)

    c = get_intersecting_letters(segment_map[1], two) |> elem(1)
    f = MapSet.difference(segment_map[1] |> string_to_map_set(), c)

    b = MapSet.difference(b_d, string_to_map_set(two))
    d = MapSet.difference(b_d, b)

    %{
      to_letter(a) => "a",
      to_letter(b) => "b",
      to_letter(c) => "c",
      to_letter(d) => "d",
      to_letter(e) => "e",
      to_letter(f) => "f",
      to_letter(g) => "g"
    }
  end

  def translate_segments(line, letter_map) do
    Enum.map(line, fn x ->
      String.codepoints(x)
      |> Enum.map(fn y ->
        letter_map[y]
      end)
      |> Enum.join("")
    end)
  end

  def convert_segments_to_number(segments) do
    Enum.map(segments, fn x ->
      Enum.find_value(@number_to_segments, fn {num, str} ->
        if is_same_letters(x, str), do: num, else: nil
      end)
    end)
    |> Enum.join("")
    |> Integer.parse(10)
    |> elem(0)
  end

  def translate_lines(lines) do
    Enum.map(lines, fn x -> translate_line(x) end)
  end

  def translate_line(line) do
    letter_map =
      (elem(line, 0) ++ elem(line, 1))
      |> get_unique_segments()
      |> discover_letters()

    translate_segments(elem(line, 1), letter_map)
    |> convert_segments_to_number()
  end

  def solve() do
    list =
      File.read!("puzzles/puzzle8.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x ->
        List.to_tuple(String.split(x, " | ") |> Enum.map(fn y -> String.split(y, " ") end))
      end)

    unique_number_frequency = SevenSegment.get_unique_number_frequency(list)

    IO.puts("Part1: #{unique_number_frequency} frequency")

    translated_lines = SevenSegment.translate_lines(list)

    IO.puts("Part2: #{Enum.sum(translated_lines)} total sum")
  end
end
