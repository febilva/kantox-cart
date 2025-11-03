defmodule Cashier.PricingRules do
  @moduledoc """
  Flexible pricing rules engine.
  Rules are composable and can be easily modified or extended.
  """

  alias Cashier.Product

  @spec default_rules() :: map()
  def default_rules do
    %{
      "GR1" => {:buy_one_get_one_free},
      "SR1" => {:bulk_discount, 3, 4.50},
      "CF1" => {:bulk_percentage_discount, 3, 2 / 3}
    }
  end

  @spec apply_rules(map(), map()) :: Decimal.t()
  def apply_rules(items_by_code, pricing_rules \\ default_rules()) do
    items_by_code
    |> Enum.reduce(Decimal.new("0.00"), fn {code, items}, total_discount ->
      quantity = length(items)
      product = hd(items)

      discount =
        case Map.get(pricing_rules, code) do
          nil ->
            Decimal.new("0.00")

          rule ->
            calculate_discount(product, quantity, rule)
        end

      # total_discount + discount
      Decimal.add(total_discount, discount)
    end)
    |> Decimal.round(2)
  end

  defp calculate_discount(_product, quantity, {:buy_one_get_one_free}) when quantity < 2 do
    Decimal.new("0.00")
  end

  defp calculate_discount(%Product{price: price}, quantity, {:buy_one_get_one_free}) do
    # For every 2 items, one is free
    free_items = div(quantity, 2)
    Decimal.mult(Decimal.new(free_items), price)
  end

  defp calculate_discount(
         _product,
         quantity,
         {:bulk_percentage_discount, min_quantity, _fraction}
       )
       when quantity < min_quantity do
    Decimal.new("0.00")
  end

  defp calculate_discount(%Product{price: price}, quantity, {
         :bulk_percentage_discount,
         _min_quantity,
         fraction
       }) do
    discount_per_item = Decimal.sub(price, Decimal.mult(price, convert_to_decimal(fraction)))
    Decimal.mult(discount_per_item, convert_to_decimal(quantity))
  end

  defp calculate_discount(_product, quantity, {:bulk_discount, min_quantity, _new_price})
       when quantity < min_quantity do
    Decimal.new("0.00")
  end

  defp calculate_discount(%Product{price: original_price}, quantity, {
         :bulk_discount,
         _min_quantity,
         new_price
       }) do
    # Discount per item * quantity
    discount_per_item = Decimal.sub(original_price, convert_to_decimal(new_price))
    Decimal.mult(discount_per_item, convert_to_decimal(quantity))
  end

  defp convert_to_decimal(value) when is_binary(value) do
    Decimal.new(value)
  end

  defp convert_to_decimal(value) when is_float(value) and not is_integer(value) do
    Decimal.from_float(value)
  end

  defp convert_to_decimal(value) when is_integer(value) do
    Decimal.new(value)
  end

  defp convert_to_decimal(%Decimal{} = value) do
    value
  end
end
