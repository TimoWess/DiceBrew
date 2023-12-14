defmodule DiceBrew.Roller do
  alias DiceBrew.FixedPart
  alias DiceBrew.RollPart
  alias DiceBrew.Result
  alias DiceBrew.Parser

  @spec roll!(Parser.dice_throw()) :: Result.t()
  def roll!(dice_throw) do
    parts = Parser.parse!(dice_throw)
    roll_value = reduce_roll_parts(parts)
    fixed_value = reduce_fixed_parts(parts)
    Result.new(total: roll_value + fixed_value, parts: parts)
  end

  @spec roll(Parser.dice_throw()) :: {:error, String.t()} | {:ok, Result.t()}
  def roll(dice_throw) do
    result = Parser.parse(dice_throw)

    case result do
      {:error, message} ->
        {:error, "Parsing error: #{message}"}

      {:ok, parts} ->
        roll_value = reduce_roll_parts(parts)
        fixed_value = reduce_fixed_parts(parts)
        total = roll_value + fixed_value
        {:ok, Result.new(total: total, parts: parts)}
    end
  end

  @spec reduce_roll_parts([Parser.part()]) :: integer()
  defp reduce_roll_parts(parts) do
    roll_parts = parts |> Enum.filter(&Parser.is_roll_part/1)

    roll_parts
    |> Enum.reduce(0, fn %RollPart{total: total}, acc -> total + acc end)
  end

  @spec reduce_fixed_parts([Parser.part()]) :: integer()
  defp reduce_fixed_parts(parts) do
    fixed_parts = parts |> Enum.filter(&Parser.is_fixed_part/1)

    fixed_parts
    |> Enum.reduce(0, fn %FixedPart{value: value}, acc -> acc + value end)
  end

  @spec get_individual_results!(Parser.dice_throw()) :: {[[integer()]], [integer()]}
  def get_individual_results!(dice_throw) when is_bitstring(dice_throw) do
    dice_throw |> Parser.parse!() |> get_individual_results()
  end

  @spec get_individual_results([Parser.part()]) :: {[[integer()]], [integer()]}
  def get_individual_results(parsed_throw) do
    dice =
      Enum.filter(parsed_throw, &Parser.is_roll_part/1)
      |> Enum.map(&RollPart.get_tally/1)

    fixed =
      Enum.filter(parsed_throw, &Parser.is_fixed_part/1)
      |> Enum.map(&FixedPart.get_value/1)

    {dice, fixed}
  end

  @spec combine_throw_parts({[[integer()]], integer()}) :: integer()
  def combine_throw_parts({roll_parts, fixed_part}),
    do: Enum.sum(List.flatten(roll_parts)) + fixed_part
end
