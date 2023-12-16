defmodule DiceBrew.PartialResult do
  alias DiceBrew.Parser

  @type label :: String.t()
  @type parts :: [Parser.part()]
  @type roll_parts :: [Parser.roll_part()]
  @type fixed_parts :: [Parser.fixed_part()]

  @type t :: %__MODULE__{
          label: label(),
          total: integer(),
          parts: parts()
        }

  defstruct label: "", total: 0, parts: []

  @spec new(label: label(), total: integer(), parts: parts()) :: t()
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

  @spec get_parts(t()) :: parts()
  def get_parts(%__MODULE__{parts: parts}), do: parts

  @spec get_roll_parts(t()) :: roll_parts()
  def get_roll_parts(%__MODULE__{parts: parts}), do: Enum.filter(parts, &Parser.is_roll_part/1)

  @spec get_fixed_parts(t()) :: fixed_parts()
  def get_fixed_parts(%__MODULE__{parts: parts}), do: Enum.filter(parts, &Parser.is_fixed_part/1)
end
