defmodule Cashier.Product do
  @moduledoc """
  Represents a product entity with its code, name, and price.
  """

  @enforce_keys [:code, :name, :price]
  defstruct [:code, :name, :price]

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          price: Decimal.t()
        }

  def new(code, name, price) when is_binary(code) and is_binary(name) do
    {:ok,
     %__MODULE__{
       code: code,
       name: name,
       price: ensure_decimal(price)
     }}
  end

  defp ensure_decimal(%Decimal{} = price), do: price
  defp ensure_decimal(price) when is_binary(price), do: Decimal.new(price)
  defp ensure_decimal(price) when is_number(price), do: Decimal.from_float(price)
end
