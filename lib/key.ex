defmodule Cardanoex.Key do
  alias Cardanoex.Backend

  def get_account_public_key(wallet_id) do
    case Backend.get_account_public_key(wallet_id) do
      {:ok, account_public_key} -> {:ok, account_public_key}
      {:error, message} -> {:error, message}
    end
  end
end
