defmodule Cardanoex.Backend do
  @moduledoc false
  def create_wallet(name, mnemonic_sentence, passphrase, mnemonic_second_factor, address_pool_gap) do
    data = %{
      name: name,
      mnemonic_sentence: mnemonic_sentence,
      passphrase: passphrase,
      address_pool_gap: address_pool_gap
    }

    data =
      if mnemonic_second_factor != nil,
        do: Map.put_new(data, :mnemonic_second_factor, mnemonic_second_factor),
        else: data

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

  def estimate_transaction_fee(wallet_id, transaction) do
    case Tesla.post(client(), "/wallets/#{wallet_id}/payment-fees", transaction) do
      {:ok, result} -> response(result)
    end
  end

  def create_transaction(wallet_id, transaction) do
    case Tesla.post(client(), "/wallets/#{wallet_id}/transactions", transaction) do
      {:ok, result} -> response(result)
    end
  end

  def list_transactions(wallet_id, start, stop, order, min_withdrawal) do
    query =
      [start: start, end: stop, order: order, minWithdrawal: min_withdrawal]
      |> Enum.filter(fn o ->
        {_, v} = o
        v != nil
      end)

    case Tesla.get(client(), "/wallets/#{wallet_id}/transactions", query: query) do
      {:ok, result} -> response(result)
    end
  end

  def get_transaction(wallet_id, transaction_id) do
    case Tesla.get(client(), "/wallets/#{wallet_id}/transactions/#{transaction_id}") do
      {:ok, result} -> response(result)
    end
  end

  def list_addresses(wallet_id) do
    case Tesla.get(client(), "/wallets/#{wallet_id}/addresses") do
      {:ok, result} -> response(result)
    end
  end

  def inspect_address(address) do
    case Tesla.get(client(), "/addresses/#{address}") do
      {:ok, result} -> response(result)
    end
  end

  def network_information() do
    case Tesla.get(client(), "/network/information") do
      {:ok, result} -> response(result)
    end
  end

  def network_clock() do
    case Tesla.get(client(), "/network/clock") do
      {:ok, result} -> response(result)
    end
  end

  def network_parameters() do
    case Tesla.get(client(), "/network/parameters") do
      {:ok, result} -> response(result)
    end
  end

  def list_assets(wallet_id) do
    case Tesla.get(client(), "/wallets/#{wallet_id}/assets") do
      {:ok, result} -> response(result)
    end
  end

  def get_asset(wallet_id, policy_id) do
    case Tesla.get(client(), "/wallets/#{wallet_id}/assets/#{policy_id}") do
      {:ok, result} -> response(result)
    end
  end

  def mint_burn_asset(wallet_id, mint_burn_info) do
    case Tesla.post(client(), "/wallets/#{wallet_id}/assets", mint_burn_info) do
      {:ok, result} -> response(result)
    end
  end

  defp response(result) do
    cond do
      Enum.member?([400, 403, 404], result.status) -> {:error, result.body["message"]}
      true -> {:ok, result.body}
    end
  end

  def client() do
    base_url_from_env = System.get_env("CARDANOEX_WALLET_BASE_URL", "http://localhost:8090/v2")
    base_url = Application.get_env(:cardanoex, :wallet_base_url, base_url_from_env)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON
    ]

    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end
end
