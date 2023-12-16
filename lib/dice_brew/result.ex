defmodule DiceBrew.Result do
  alias DiceBrew.PartialResult
  alias DiceBrew.Parser

  @type label :: String.t()
  @type partial_results :: [PartialResult.t()]

  @type t :: %__MODULE__{
          label: label(),
          total: integer(),
          partial_results: partial_results()
        }

  defstruct label: "", total: 0, partial_results: []

  @spec new(label: label(), total: integer(), partial_results: partial_results()) :: t()
  def new(options \\ []) do
    struct(%__MODULE__{}, options)
  end

  @spec to_struct(map()) :: t()
  def to_struct(map) do
    struct(__MODULE__, map)
  end

  @spec get_label(t()) :: label()
  def get_label(%__MODULE__{label: label}), do: label

  @spec get_total(t()) :: integer()
  def get_total(%__MODULE__{total: total}), do: total

  @spec get_partial_results(t()) :: partial_results()
  def get_partial_results(%__MODULE__{partial_results: parts}), do: parts
end
