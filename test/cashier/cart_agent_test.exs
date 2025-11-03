defmodule Cashier.Agent.CartTest do
  alias Cashier.Agent.Cart
  use ExUnit.Case, async: true

  setup do
    {:ok, green_tea} = Cashier.Product.new("GR1", "Green tea", "3.11")
    {:ok, strawberries} = Cashier.Product.new("SR1", "Strawberries", "5.00")
    {:ok, coffee} = Cashier.Product.new("CF1", "Coffee", "11.23")
    {:ok, agent} = Cart.start_link()
    %{agent: agent, green_tea: green_tea, strawberries: strawberries, coffee: coffee}
  end

  describe "add_item/2" do
    test "adds a single item", %{agent: agent, green_tea: green_tea} do
      assert :ok = Cart.add_item(agent, green_tea)

      items = Cart.get_items(agent)
      assert {:ok, [^green_tea]} = items
    end

    test "allows duplicate items", %{agent: agent, green_tea: green_tea} do
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, green_tea)

      items = Cart.get_items(agent)
      assert {:ok, [^green_tea, ^green_tea]} = items
    end

    test "handles nil item", %{agent: agent} do
      assert :invalid_product = Cart.add_item(agent, nil)

      items = Cart.get_items(agent)
      assert {:ok, []} = items
    end

    test "handles empty string item", %{agent: agent} do
      assert :invalid_product = Cart.add_item(agent, "")

      items = Cart.get_items(agent)
      assert {:ok, []} = items
    end
  end

  describe "get_items/1" do
    test "returns all items after multiple additions", %{
      agent: agent,
      green_tea: green_tea,
      strawberries: strawberries,
      coffee: coffee
    } do
      assert :ok = Cart.add_item(agent, green_tea)
      assert :ok = Cart.add_item(agent, strawberries)
      assert :ok = Cart.add_item(agent, coffee)

      {:ok, items} = Cart.get_items(agent)
      assert green_tea in items
      assert strawberries in items
      assert coffee in items
    end
  end
end
