defmodule DiceBrew.Roller do
  alias DiceBrew.RollOptions
  alias DiceBrew.FixedPart
  alias DiceBrew.RollPart
  alias DiceBrew.Result
  alias DiceBrew.Parser

  @spec roll!(Parser.dice_throw(), String.t()) :: Result.t()
  def roll!(dice_throw, label \\ "") do
    parts =
      Parser.parse!(dice_throw)
      |> Enum.map(fn e -> if Parser.is_roll_part(e), do: evaluate_roll_part(e), else: e end)

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
        parts =
          Enum.map(parts, fn e ->
            if Parser.is_roll_part(e), do: evaluate_roll_part(e), else: e
          end)

        roll_value = reduce_roll_parts(parts)
        fixed_value = reduce_fixed_parts(parts)
        total = roll_value + fixed_value
        {:ok, %Result{total: total, parts: parts, label: label}}
    end
  end

  def evaluate_roll_part(roll_part) when is_struct(roll_part, RollPart) do
    roll_part
    |> apply_roll_part_options()
    |> update_total_with_exploding_series()
  end

  defp singular_roll(%RollPart{sides: sides, sign: sign}) do
    range =
      case sign do
        :plus -> 1..sides
        :minus -> -1..-sides
      end

    Enum.random(range)
  end

  defp apply_roll_part_options(roll_part) when is_struct(roll_part, RollPart) do
    roll_part
    |> apply_explode_and_reroll()
    |> apply_keep_and_drop()
  end

  defp apply_explode_and_reroll(roll_part) when is_struct(roll_part, RollPart) do
    %RollOptions{
      explode: explode,
      explode_indefinite: explode_indefinite,
      reroll: reroll,
      reroll_indefinite: reroll_indefinite
    } = roll_part.options

    rolled_value = singular_roll(roll_part)

    result =
      cond do
        rolled_value in explode ->
          IO.puts("Rolled: #{rolled_value} -> Single Explode")

          %RollPart{
            roll_part
            | options: %RollOptions{roll_part.options | explode: []},
              exploding_series: [rolled_value | roll_part.exploding_series]
          }

        rolled_value in explode_indefinite ->
          IO.puts("Rolled: #{rolled_value} -> Indefinite Explode")
          %RollPart{roll_part | exploding_series: [rolled_value | roll_part.exploding_series]}

        rolled_value in reroll ->
          IO.puts("Rolled: #{rolled_value} -> Single Reroll")

          %RollPart{
            roll_part
            | options: %RollOptions{roll_part.options | reroll: []},
              reroll_count: roll_part.reroll_count + 1
          }

        rolled_value in reroll_indefinite ->
          IO.puts("Rolled: #{rolled_value} -> Indefinite Reroll")
          %RollPart{roll_part | reroll_count: roll_part.reroll_count + 1}

        true ->
          IO.puts("Rolled: #{rolled_value}")

          %RollPart{
            roll_part
            | tally: [rolled_value | roll_part.tally],
              total: roll_part.total + rolled_value
          }
      end

    if length(result.tally) == result.amount, do: result, else: apply_explode_and_reroll(result)
  end

  defp apply_keep_and_drop(roll_part) when is_struct(roll_part, RollPart) do
    %RollOptions{
      drop: drop,
      keep: keep,
      keeplowest: keeplowest
    } = roll_part.options

    tally = roll_part.tally

    new_tally =
      cond do
        keeplowest > 0 ->
          tally |> Enum.sort() |> Enum.take(keeplowest)

        keep > 0 ->
          tally |> Enum.sort(:desc) |> Enum.take(keep)

        drop > 0 ->
          tally |> Enum.sort() |> Enum.drop(drop)

        true ->
          tally
      end

    %RollPart{roll_part | tally: new_tally}
  end

  defp update_total_with_exploding_series(
         %RollPart{tally: tally, exploding_series: exploding_series} = roll_part
       ) do
    tally_sum = Enum.sum(tally)
    exploding_series_sum = Enum.sum(exploding_series)
    %RollPart{roll_part | exploded_total: tally_sum + exploding_series_sum, total: tally_sum}
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
