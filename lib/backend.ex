defmodule Cardano.Backend do
  def create_wallet(name, mnemonic_sentence, passphrase, mnemonic_second_factor, address_pool_gap) do
    data = %{
      name: name,
      mnemonic_sentence: mnemonic_sentence,
      passphrase: passphrase,
      address_pool_gap: address_pool_gap
    }

    if mnemonic_second_factor != nil,
      do: Map.put_new(data, :mnemonic_second_factor, mnemonic_second_factor)

    case Tesla.post(client(), "/wallets", data) do
      {:ok, result} -> response(result)
    end
  end

  def fetch_wallet(id) do
    case Tesla.get(client(), "/wallets/#{id}") do
      {:ok, result} -> response(result)
    end
  end

  def list_wallets() do
    case Tesla.get(client(), "/wallets") do
      {:ok, result} -> response(result)
    end
  end

  def delete_wallet(id) do
    case Tesla.delete(client(), "/wallets/#{id}") do
      {:ok, result} -> response(result)
    end
  end

  def fetch_wallet_utxo_stats(id) do
    case Tesla.get(client(), "/wallets/#{id}/statistics/utxos") do
      {:ok, result} -> response(result)
    end
  end

  def update_wallet_metadata(id, name) do
    data = %{name: name}

    case Tesla.put(client(), "/wallets/#{id}", data) do
      {:ok, result} -> response(result)
    end
  end

  def update_wallet_passphrase(id, old_passphrase, new_passphrase) do
    data = %{old_passphrase: old_passphrase, new_passphrase: new_passphrase}

    case Tesla.put(client(), "/wallets/#{id}/passphrase", data) do
      {:ok, result} -> response(result)
    end
  end

  defp response(result) do
    cond do
      # This is probably due to a bug in the Cardano wallet: https://github.com/input-output-hk/cardano-wallet/issues/2596
      result.status == 404 -> {:error, Jason.decode!(result.body)["message"]}
      result.status == 403 -> {:error, Jason.decode!(result.body)["message"]}
      result.status == 400 -> {:error, result.body["message"]}
      true -> {:ok, result.body}
    end
  end

  def client() do
    base_url = Application.get_env(:cardano, :wallet_base_url, "http://localhost:8090/v2")

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
