defmodule Cashier.ProductTest do
  use ExUnit.Case, async: true
  doctest Cashier.Product

  alias Cashier.Product

  describe "new/3" do
    test "creates a product with valid parameters" do
      {:ok, product} = Product.new("GR1", "Green tea", Decimal.new("3.11"))

      assert product.code == "GR1"
      assert product.name == "Green tea"
      assert Decimal.equal?(product.price, Decimal.new("3.11"))
    end

    test "accepts string price and converts to Decimal" do
      {:ok, product} = Product.new("SR1", "Strawberries", "5.00")

      assert Decimal.equal?(product.price, Decimal.new("5.00"))
    end

    test "accepts numeric price and converts to Decimal" do
      {:ok, product} = Product.new("CF1", "Coffee", 11.23)

      assert Decimal.equal?(product.price, Decimal.new("11.23"))
    end
  end
end
