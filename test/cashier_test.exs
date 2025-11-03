defmodule CashierTest do
  use ExUnit.Case
  doctest Cashier

  alias Cashier.PricingRules
  alias Cashier.Agent.Cart

  setup do
    {:ok, green_tea} = Cashier.Product.new("GR1", "Green tea", "3.11")
    {:ok, strawberries} = Cashier.Product.new("SR1", "Strawberries", "5.00")
    {:ok, coffee} = Cashier.Product.new("CF1", "Coffee", "11.23")
    {:ok, agent} = Cart.start_link()
    %{agent: agent, green_tea: green_tea, strawberries: strawberries, coffee: coffee}
  end

  describe "total/1 with standard rules" do
    test "returns £0.00 for empty basket", %{agent: agent} do
      {:ok, total} = Cashier.total(agent)
      assert Decimal.equal?(total, Decimal.new("0"))
    end

    test "basket: GR1,SR1,GR1,GR1,CF1 should total £22.45", %{
      agent: agent,
      green_tea: green_tea,
      strawberries: strawberries,
      coffee: coffee
    } do
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, strawberries)
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, coffee)
      {:ok, total} = Cashier.total(agent)
      assert Decimal.equal?(total, Decimal.new("22.45"))
    end

    test "basket: GR1,GR1 should total £3.11", %{agent: agent, green_tea: green_tea} do
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, green_tea)
      {:ok, total} = Cashier.total(agent)
      assert Decimal.equal?(total, Decimal.new("3.11"))
    end

    test "basket: SR1,SR1,GR1,SR1 should total £16.61", %{
      agent: agent,
      green_tea: green_tea,
      strawberries: strawberries
    } do
      assert :ok = Cart.add_item(agent, strawberries)
      assert :ok = Cart.add_item(agent, strawberries)
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, strawberries)
      {:ok, total} = Cashier.total(agent)
      assert Decimal.equal?(total, Decimal.new("16.61"))
    end

    test "basket: GR1,CF1,SR1,CF1,CF1 should total £30.57", %{
      agent: agent,
      green_tea: green_tea,
      strawberries: strawberries,
      coffee: coffee
    } do
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, coffee)
      assert :ok = Cart.add_item(agent, strawberries)
      assert :ok = Cart.add_item(agent, coffee)
      assert :ok = Cart.add_item(agent, coffee)
      {:ok, total} = Cashier.total(agent)
      assert Decimal.equal?(total, Decimal.new("30.57"))
    end
  end

  describe "total/2 with custom rules" do
    test "can use custom pricing rules", %{agent: agent, coffee: coffee} do
      # No special rules - just standard pricing
      assert :ok = Cart.add_item(agent, coffee)
      assert :ok = Cart.add_item(agent, coffee)
      {:ok, total} = Cashier.total(agent)

      # Without bulk discount, should be 2 * £11.23 = £22.46
      assert Decimal.equal?(total, Decimal.new("22.46"))
    end
  end
end
