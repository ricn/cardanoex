defmodule Cardanoex.Address do
  alias Cardanoex.Backend

  def list(wallet_id) do
    Backend.list_addresses(wallet_id)
  end

  def inspect(address) do
    Backend.inspect_address(address)
  end
end
