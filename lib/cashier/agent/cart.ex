defmodule Agent.Cart do
  @moduledoc """
  Defines a simple `Agent` that holds a list of items for a cart.
  """
  use Agent

  alias Cashier.Product

  @spec start_link(keyword()) :: Agent.on_start()
  def start_link(options \\ []) do
    Agent.start_link(fn -> [] end, options)
  end

  @spec get_items(agent :: pid()) :: {:ok, [Product.t() | nil]}
  def get_items(agent) do
    Agent.get(agent, fn items -> {:ok, items} end)
  end

  @spec add_item(agent :: pid(), product :: Product.t()) :: :ok | :invalid_product
  def add_item(agent, %Product{} = product) do
    Agent.update(agent, fn items -> [product | items] end)
  end

  def add_item(_agent, nil) do
    :invalid_product
  end

  def add_item(_agent, "") do
    :invalid_product
  end
end
