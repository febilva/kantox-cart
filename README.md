# Cashier



## Cashier System

A checkout system for calculating totals with promotional pricing rules, built in Elixir. It leverages Elixir's Agent for managing cart state and the Decimal library for accurate currency arithmetic.

### Features

- **Agent-based cart:** Maintains a stateful shopping cart using Elixir Agent processes.
- **Pricing rules:** Supports configurable promotional pricing rules for flexible discounts and offers.
- **Precise calculations:** Uses the `Decimal` library for accurate monetary computations.
- **Type-safe products:** Defines products as validated structs.



Usage
Basic Example


```elixir
# Create products
{:ok, green_tea} = Cashier.Product.new("GR1", "Green tea", "3.11")
{:ok, strawberries} = Cashier.Product.new("SR1", "Strawberries", "5.00")
{:ok, coffee} = Cashier.Product.new("CF1", "Coffee", "11.23")

# Start a cart
{:ok, cart} = Cashier.Agent.Cart.start_link()

# Add items to cart
alias Cashier.Agent.Cart
Cart.add_item(cart, green_tea)
Cart.add_item(cart, strawberries)
Cart.add_item(cart, green_tea)

# Calculate total with default pricing rules
{:ok, total} = Cashier.total(cart)
# => {:ok, #Decimal<...>}
```