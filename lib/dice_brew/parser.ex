defmodule DiceBrew.Parser do
  @notation_pattern ~r/^(([+-]?)(?:(\d+)d(\d+)|(\d+)))+$/
  @single_pattern ~r/(?<sign>[+-]?)(?:(?<amount>\d+)d(?<sides>\d+)|(?<fixed>\d+))/

  @type dice_throw() :: String.t()
  @type sign() :: :plus | :minus
  @type roll_part() :: {:dice, sign(), non_neg_integer(), non_neg_integer()}
  @type fixed_part() :: {:fixed, sign(), non_neg_integer()}
  @type part() :: roll_part() | fixed_part()

  @spec get_sign(String.t()) :: sign()
  defp get_sign(""), do: :plus
  defp get_sign("+"), do: :plus
  defp get_sign("-"), do: :minus

  @spec sanitise_dice(dice_throw()) :: dice_throw()
  defp sanitise_dice(dice) do
    dice
    |> String.downcase()
    |> String.replace(" ", "")
  end

  @spec parse(dice_throw()) :: {:error, String.t()} | {:ok, [part()]}
  def parse(dice) do
    dice = sanitise_dice(dice)

    if Regex.scan(@notation_pattern, dice) == [] do
      {:error, "Pattern does not match dice notation rules!"}
    else
      {:ok, Regex.scan(@single_pattern, dice) |> Enum.map(&_parse/1)}
    end
  end

  @spec parse!(dice_throw()) :: [part()]
  def parse!(dice) do
    dice = sanitise_dice(dice)

    if Regex.scan(@notation_pattern, dice) == [],
      do: raise(ArgumentError, "Pattern does not match dice notation rules!")

    Regex.scan(@single_pattern, dice) |> Enum.map(&_parse/1)
  end

  @spec _parse([String.t()]) :: part()
  defp _parse([_part, sign, amount, value]),
    do: {
      :dice,
      get_sign(sign),
      Integer.parse(amount) |> elem(0),
      Integer.parse(value) |> elem(0)
    }

  @spec _parse([String.t()]) :: part()
  defp _parse([_part, sign, _, _, value]) do
    {
      :fixed,
      get_sign(sign),
      Integer.parse(value) |> elem(0)
    }
  end

  @spec expand_parts!(dice_throw()) :: {[[[integer()]]], [integer()]}
  def expand_parts!(dice_throw) do
    dice_throw |> parse!() |> expand_parts()
  end

  @spec expand_parts([part()]) :: {[[[integer()]]], [integer()]}
  def expand_parts(parts) do
    roll_parts = parts |> Enum.filter(&(elem(&1, 0) == :dice))
    fixed_parts = parts |> Enum.filter(&(elem(&1, 0) == :fixed))

    expanded_rolls =
      roll_parts
      |> Enum.map(fn {_, sign, amount, sides} ->
        Enum.map(1..amount, fn _ ->
          Enum.to_list(if sign == :plus, do: 1..sides, else: -1..-sides)
        end)
      end)

    expanded_fixed =
      fixed_parts
      |> Enum.map(fn {_, sign, value} -> if sign == :plus, do: value, else: -value end)

    {expanded_rolls, expanded_fixed}
  end
end
