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

  @spec is_dice_part(roll_part() | any()) :: boolean()
  defp is_dice_part({:dice, _, _, _}), do: true
  defp is_dice_part(_), do: false

  @spec is_fixed_part(fixed_part() | any()) :: boolean()
  defp is_fixed_part({:fixed, _, _}), do: true
  defp is_fixed_part(_), do: false

  @spec sanitise_dice(dice_throw()) :: dice_throw()
  defp sanitise_dice(dice) do
    dice
    |> String.downcase()
    |> String.replace(" ", "")
  end

  @spec parse(dice_throw()) :: {:error, String.t()} | {:ok, [part()]}
  def parse(dice) do
    sanitized_dice = sanitise_dice(dice)

    if Regex.scan(@notation_pattern, sanitized_dice) == [] do
      {:error, "Pattern does not match dice notation rules!"}
    else
      {:ok, Regex.scan(@single_pattern, sanitized_dice) |> Enum.map(&_parse/1)}
    end
  end

  @spec parse!(dice_throw()) :: [part()]
  def parse!(dice) do
    sanitized_dice = sanitise_dice(dice)

    if Regex.scan(@notation_pattern, sanitized_dice) == [],
      do: raise(ArgumentError, "Pattern does not match dice notation rules!")

    Regex.scan(@single_pattern, sanitized_dice) |> Enum.map(&_parse/1)
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
    dice_throw |> parse!() |> expand_parts() |> elem(1)
  end

  @spec expand_parts(String.t()) :: {:ok, {[[[integer()]]], [integer()]}} | {:error, String.t()}
  def expand_parts(dice_throw) when is_bitstring(dice_throw) do
    result = parse(dice_throw)
    case result do
      {:error, message} -> {:error, "Parsing error: #{message}"}
      {:ok, parts} -> expand_parts(parts)
    end
  end

  @spec expand_parts([part()]) :: {:ok, {[[[integer()]]], [integer()]}}
  def expand_parts(parts) when is_list(parts) do
    roll_parts = Enum.filter(parts, &is_dice_part/1)
    fixed_parts = Enum.filter(parts, &is_fixed_part/1)

    expanded_rolls =
      roll_parts
      |> Enum.map(&expand_roll/1)

    expanded_fixed =
      fixed_parts
      |> Enum.map(&apply_fixed_sign/1)

    {:ok, {expanded_rolls, expanded_fixed}}
  end

  @spec expand_roll(roll_part()) :: [[integer()]]
  defp expand_roll({:dice, sign, amount, sides}) do
    Enum.map(1..amount, fn _ ->
      Enum.to_list(if sign == :plus, do: 1..sides, else: -1..-sides)
    end)
  end

  @spec apply_fixed_sign(fixed_part()) :: integer()
  defp apply_fixed_sign({:fixed, sign, value}) do
    if sign == :plus, do: value, else: -value
  end
end
