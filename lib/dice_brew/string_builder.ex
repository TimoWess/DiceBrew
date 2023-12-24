defmodule DiceBrew.StringBuilder do
  alias DiceBrew.RollPart
  alias DiceBrew.FixedPart
  alias DiceBrew.PartialResult
  alias DiceBrew.Result

  defp get_sign_string(sign) do
    case sign do
      :plus -> "+"
      :minus -> "-"
      true -> sign
    end
  end

  @spec to_string(RollPart.t()) :: String.t()
  def to_string(%RollPart{total: total}) do
    "#{total}"
  end

  @spec to_string(FixedPart.t()) :: String.t()
  def to_string(%FixedPart{value: value}) do
    "#{value}"
  end

  @spec to_string(PartialResult.t()) :: String.t()
  def to_string(%PartialResult{label: label, total: total, parts: parts}) do
    parts_string = parts |> Enum.map(&__MODULE__.to_string/1) |> Enum.join(", ")
    "#{if label != "", do: "#{label}", else: "Roll"}: [#{parts_string}] Result: #{total}"
  end

  @spec to_string(Result.t()) :: String.t()
  def to_string(%Result{label: label, total: total, partial_results: partial_results}) do
    "#{if label != "", do: "#{label}", else: "Result"}: #{total}\n#{Enum.map(partial_results, &__MODULE__.to_string/1) |> Enum.join("\n")}"
  end
end
