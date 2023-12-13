defmodule DiceBrew.Roller do
  alias DiceBrew.Parser

  @spec roll!(Parser.dice_throw()) :: integer()
  def roll!(dice_throw) do
    parts = Parser.parse!(dice_throw)
    roll_value = reduce_roll_parts(parts)
    fixed_value = reduce_fixed_parts(parts)
    roll_value + fixed_value
  end

  @spec roll(Parser.dice_throw()) :: {:error, String.t()} | {:ok, integer()}
  def roll(dice_throw) do
    {status, parts} = Parser.parse(dice_throw)

    case status do
      :error ->
        {:error, parts}

      :ok ->
        roll_value = reduce_roll_parts(parts)
        fixed_value = reduce_fixed_parts(parts)
        {:ok, roll_value + fixed_value}
    end
  end

  @spec reduce_roll_parts([Parser.roll_part()]) :: integer()
  defp reduce_roll_parts(parts) do
    roll_parts = parts |> Enum.filter(&(elem(&1, 0) == :dice))

    roll_parts
    |> Enum.reduce(0, fn {_, sign, amount, sides}, acc ->
      case sign do
        :plus ->
          Enum.sum(Enum.map(1..amount, fn _ -> Enum.random(1..sides) end)) + acc

        :minus ->
          Enum.sum(Enum.map(1..amount, fn _ -> Enum.random(-1..-sides) end)) + acc
      end
    end)
  end

  @spec reduce_fixed_parts([Parser.fixed_part()]) :: integer()
  defp reduce_fixed_parts(parts) do
    fixed_parts = parts |> Enum.filter(&(elem(&1, 0) == :fixed))

    fixed_parts
    |> Enum.reduce(0, fn {_, sign, value}, acc ->
      case sign do
        :plus ->
          acc + value

        :minus ->
          acc - value
      end
    end)
  end

  @spec get_individual_results!(Parser.dice_throw()) :: {[[integer()]], integer()}
  def get_individual_results!(dice_throw) when is_bitstring(dice_throw) do
    dice_throw |> Parser.parse!() |> get_individual_results()
  end

  @spec get_individual_results([Parser.part()]) :: {[[integer()]], integer()}
  def get_individual_results(parsed_throw) do
    dice =
      Enum.filter(parsed_throw, fn e -> elem(e, 0) == :dice end)
      |> Enum.map(fn {_, sign, amount, value} ->
        case sign do
          :plus -> Enum.map(1..amount, fn _ -> Enum.random(1..value) end)
          :minus -> Enum.map(1..amount, fn _ -> Enum.random(-1..-value) end)
        end
      end)

    fixed =
      Enum.filter(parsed_throw, fn e -> elem(e, 0) == :fixed end)
      |> Enum.reduce(0, fn {_, sign, value}, acc ->
        case sign do
          :plus -> acc + value
          :minus -> acc - value
        end
      end)

    {dice, fixed}
  end

  @spec combine_throw_parts({[[integer()]], integer()}) :: integer()
  def combine_throw_parts({roll_parts, fixed_part}),
    do: Enum.sum(List.flatten(roll_parts)) + fixed_part
end
