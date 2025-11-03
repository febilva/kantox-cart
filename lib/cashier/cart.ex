defmodule Cashier.Cart do
  @moduledoc """
  Shopping cart that holds items and their quantities.

  The cart tracks product codes and their quantities, validating against
  the product catalog.
  """

  alias Cashier.Catalog

  @enforce_keys [:items]
  defstruct items: %{}

  @type t :: %__MODULE__{
          items: %{String.t() => non_neg_integer()}
        }

  @doc """
  Creates a new cart from a list of product codes.

  ## Examples

      iex> Cashier.Cart.new(["GR1", "SR1", "GR1"])
      {:ok, %Cashier.Cart{items: %{"GR1" => 2, "SR1" => 1}}}
  """
  def new(product_codes) when is_list(product_codes) do
    case validate_products(product_codes) do
      :ok ->
        items =
          product_codes
          |> Enum.frequencies()

        {:ok, %__MODULE__{items: items}}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Creates an empty cart.
  """
  def empty do
    %__MODULE__{items: %{}}
  end

  @doc """
  Adds an item to the cart.
  """
  def add_item(%__MODULE__{items: items} = cart, product_code) do
    case Catalog.product_exists?(product_code) do
      true ->
        updated_items = Map.update(items, product_code, 1, &(&1 + 1))
        {:ok, %{cart | items: updated_items}}

      false ->
        {:error, {:invalid_product, product_code}}
    end
  end

  @doc """
  Removes an item from the cart.
  """
  def remove_item(%__MODULE__{items: items} = cart, product_code) do
    case Map.get(items, product_code) do
      nil ->
        {:ok, cart}

      1 ->
        {:ok, %{cart | items: Map.delete(items, product_code)}}

      quantity when quantity > 1 ->
        {:ok, %{cart | items: Map.put(items, product_code, quantity - 1)}}
    end
  end

  @doc """
  Returns the quantity of a specific product in the cart.
  """
  def quantity(%__MODULE__{items: items}, product_code) do
    Map.get(items, product_code, 0)
  end

  @doc """
  Returns total number of items in the cart.
  """
  def total_items(%__MODULE__{items: items}) do
    items
    |> Map.values()
    |> Enum.sum()
  end

  @doc """
  Checks if the cart is empty.
  """
  def empty?(%__MODULE__{items: items}) do
    Enum.empty?(items)
  end

  # Private functions

  defp validate_products(product_codes) do
    invalid_products =
      product_codes
      |> Enum.uniq()
      |> Enum.reject(&Catalog.product_exists?/1)

    case invalid_products do
      [] -> :ok
      [code | _] -> {:error, {:invalid_product, code}}
    end
  end
end
