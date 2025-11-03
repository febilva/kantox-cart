defmodule Cashier do
  alias Cashier.Agent.Cart
  alias Cashier.PricingRules

  @moduledoc "Main module for the Cashier system"

  @doc """
  Calculates the total price for a cart of items.

  ## Parameters

    - cart: cart agent pid
    - rules: Optional custom pricing rules (defaults to default rules)

  ## Returns

    - {:ok, total} - Successfully calculated total as Decimal
  """
  @spec total(pid(), map()) :: {:ok, Decimal.t()}
  def total(cart, rules \\ PricingRules.default_rules()) when is_pid(cart) do
    {:ok, items} = Cart.get_items(cart)
    items_by_code = items |> Enum.group_by(& &1.code)

    subtotal =
      items
      |> Enum.reduce(Decimal.new("0.00"), fn product, acc -> Decimal.add(acc, product.price) end)

    # Calculate discount
    discount = PricingRules.apply_rules(items_by_code, rules)

    {:ok, Decimal.sub(subtotal, discount)}
  end
end
