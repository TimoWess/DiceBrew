defmodule DiceBrew.Roller do
  alias DiceBrew.FixedPart
  alias DiceBrew.RollPart
  alias DiceBrew.Result
  alias DiceBrew.Parser

  @spec roll!(Parser.dice_throw(), String.t()) :: Result.t()
  def roll!(dice_throw, label \\ "") do
    parts = Parser.parse!(dice_throw)
    roll_value = reduce_roll_parts(parts)
    fixed_value = reduce_fixed_parts(parts)
    %Result{total: roll_value + fixed_value, parts: parts, label: label}
  end

  @spec roll(Parser.dice_throw(), String.t()) :: {:error, String.t()} | {:ok, Result.t()}
  def roll(dice_throw, label \\ "") do
    result = Parser.parse(dice_throw)

    case result do
      {:error, message} ->
        {:error, "Parsing error: #{message}"}

      {:ok, parts} ->
        roll_value = reduce_roll_parts(parts)
        fixed_value = reduce_fixed_parts(parts)
        total = roll_value + fixed_value
        {:ok, %Result{total: total, parts: parts, label: label}}
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

  @spec get_individual_results!(Parser.dice_throw() | [Parser.part()]) ::
          {[[integer()]], [integer()]}
  def get_individual_results!(dice_throw) when is_bitstring(dice_throw) do
    dice_throw |> Parser.parse!() |> get_individual_results!()
  end

  def get_individual_results!(parsed_throw) do
    rolls =
      Enum.filter(parsed_throw, &Parser.is_roll_part/1)
      |> Enum.map(&RollPart.get_tally/1)

    fixed =
      Enum.filter(parsed_throw, &Parser.is_fixed_part/1)
      |> Enum.map(&FixedPart.get_value/1)

    {rolls, fixed}
  end

  @spec get_individual_results(Parser.dice_throw() | [Parser.part()]) ::
          {:error, String.t()} | {:ok, {[[integer()]], [integer()]}}
  def get_individual_results(dice_throw) when is_bitstring(dice_throw) do
    result = Parser.parse(dice_throw)

    case result do
      {:error, message} -> {:error, "Parsing error: #{message}"}
      {:ok, parts} -> get_individual_results(parts)
    end
  end

  @spec get_individual_results([Parser.part()]) :: {[[integer()]], [integer()]}
  def get_individual_results(parsed_throw) do
    rolls =
      Enum.filter(parsed_throw, &Parser.is_roll_part/1)
      |> Enum.map(&RollPart.get_tally/1)

    fixed =
      Enum.filter(parsed_throw, &Parser.is_fixed_part/1)
      |> Enum.map(&FixedPart.get_value/1)

    {:ok, {rolls, fixed}}
  end
end
