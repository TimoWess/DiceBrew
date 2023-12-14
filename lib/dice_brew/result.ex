defmodule DiceBrew.Result do
  alias DiceBrew.Parser

  @type label :: String.t()
  @type parts :: [Parser.part()]

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
end
