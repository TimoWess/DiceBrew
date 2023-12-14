defmodule DiceBrew.StringBuilder do
  alias DiceBrew.Result

  @spec to_string(Result.t()) :: String.t()
  def to_string(%Result{label: label, total: total, parts: parts}) do
    "#{if label != "", do: "#{label}: "}#{total}"
  end
end
