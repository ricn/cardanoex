defmodule Cardanoex.Backend do
  @moduledoc false

  @spec create_wallet(String.t(), String.t(), String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, any}
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

    post("/wallets", data)
  end

  @spec fetch_wallet(String.t()) :: {:error, String.t()} | {:ok, list()}
  def fetch_wallet(id), do: get("/wallets/#{id}")

  @spec list_wallets :: {:error, String.t()} | {:ok, list()}
  def list_wallets(), do: get("/wallets")

  @spec delete_wallet(String.t()) :: {:error, String.t()} | {:ok, any}
  def delete_wallet(id), do: delete("/wallets/#{id}")

  @spec fetch_wallet_utxo_stats(String.t()) :: {:error, String.t()} | {:ok, any}
  def fetch_wallet_utxo_stats(id), do: get("/wallets/#{id}/statistics/utxos")

  @spec update_wallet_metadata(String.t(), String.t()) :: {:error, String.t()} | {:ok, any}
  def update_wallet_metadata(id, name), do: put("/wallets/#{id}", %{name: name})

  @spec update_wallet_passphrase(String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, any}
  def update_wallet_passphrase(id, old_passphrase, new_passphrase) do
    data = %{old_passphrase: old_passphrase, new_passphrase: new_passphrase}
    put("/wallets/#{id}/passphrase", data)
  end

  @spec estimate_transaction_fee(String.t(), map()) :: {:error, String.t()} | {:ok, map()}
  def estimate_transaction_fee(wallet_id, transaction),
    do: post("/wallets/#{wallet_id}/payment-fees", transaction)

  @spec create_transaction(String.t(), map()) :: {:error, String.t()} | {:ok, map()}
  def create_transaction(wallet_id, transaction),
    do: post("/wallets/#{wallet_id}/transactions", transaction)

  @spec list_transactions(String.t(), String.t(), String.t(), atom(), non_neg_integer()) ::
          {:error, String.t()} | {:ok, list(map())}
  def list_transactions(wallet_id, start, stop, order, min_withdrawal) do
    query =
      [start: start, end: stop, order: order, minWithdrawal: min_withdrawal]
      |> Enum.filter(fn o ->
        {_, v} = o
        v != nil
      end)

    get("/wallets/#{wallet_id}/transactions", query: query)
  end

  @spec get_transaction(String.t(), String.t()) :: {:error, String.t()} | {:ok, map()}
  def get_transaction(wallet_id, transaction_id),
    do: get("/wallets/#{wallet_id}/transactions/#{transaction_id}")

  @spec list_addresses(String.t()) :: {:error, String.t()} | {:ok, list(map())}
  def list_addresses(wallet_id), do: get("/wallets/#{wallet_id}/addresses")

  @spec inspect_address(String.t()) :: {:error, String.t()} | {:ok, map()}
  def inspect_address(address), do: get("/addresses/#{address}")

  @spec network_information :: {:error, String.t()} | {:ok, map()}
  def network_information(), do: get("/network/information")

  @spec network_clock :: {:error, String.t()} | {:ok, map()}
  def network_clock(), do: get("/network/clock")

  @spec network_parameters :: {:error, String.t()} | {:ok, map()}
  def network_parameters(), do: get("/network/parameters")

  @spec list_assets(String.t()) :: {:error, String.t()} | {:ok, list(map())}
  def list_assets(wallet_id), do: get("/wallets/#{wallet_id}/assets")

  @spec get_asset(String.t(), String.t()) :: {:error, String.t()} | {:ok, map()}
  def get_asset(wallet_id, policy_id), do: get("/wallets/#{wallet_id}/assets/#{policy_id}")

  @spec list_stake_pools(non_neg_integer()) :: {:error, String.t()} | {:ok, list(map())}
  def list_stake_pools(stake), do: get("/stake-pools", query: [stake: stake])

  @spec list_stake_keys(String.t()) :: {:error, String.t()} | {:ok, list(map())}
  def list_stake_keys(wallet_id), do: get("/wallets/#{wallet_id}/stake-keys")

  @spec view_maintenance_actions :: {:error, String.t()} | {:ok, map()}
  def view_maintenance_actions, do: get("/stake-pools/maintenance-actions")

  @spec trigger_maintenance_action(String.t()) :: {:error, String.t()} | {:ok, any}
  def trigger_maintenance_action(action),
    do: post("/stake-pools/maintenance-actions", %{maintenance_action: action})

  @spec join_stake_pool(String.t(), String.t(), String.t()) :: {:error, String.t()} | {:ok, map()}
  def join_stake_pool(wallet_id, stake_pool_id, passphrase),
    do:
      put("/stake-pools/#{stake_pool_id}/wallets/#{wallet_id}", %{
        passphrase: passphrase
      })

  @spec quit_staking(String.t(), String.t()) :: {:error, String.t()} | {:ok, map()}
  def quit_staking(wallet_id, passphrase),
    do:
      delete("/stake-pools/*/wallets/#{wallet_id}", %{
        passphrase: passphrase
      })

  @spec delegation_fees(String.t()) :: {:error, String.t()} | {:ok, map()}
  def delegation_fees(wallet_id), do: get("/wallets/#{wallet_id}/delegation-fees")

  @spec get_account_public_key(String.t()) :: {:error, String.t()} | {:ok, String.t()}
  def get_account_public_key(wallet_id), do: get("/wallets/#{wallet_id}/keys")

  @spec get_public_key(String.t(), String.t(), String.t()) ::
          {:error, String.t()} | {:ok, String.t()}
  def get_public_key(wallet_id, role, index),
    do: get("/wallets/#{wallet_id}/keys/#{role}/#{index}")

  @spec create_account_public_key(
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t() | nil
        ) ::
          {:error, String.t()} | {:ok, String.t()}
  def create_account_public_key(wallet_id, passphrase, index, format, purpose \\ nil) do
    data = %{
      passphrase: passphrase,
      format: format
    }

    data = if purpose != nil, do: Map.put_new(data, :purpose, purpose), else: data

    post("/wallets/#{wallet_id}/keys/#{index}", data)
  end

  defp get(url, query \\ []) do
    case Tesla.get(client(), url, query) do
      {:ok, result} -> response(result)
    end
  end

  defp post(url, data) do
    case Tesla.post(client(), url, data) do
      {:ok, result} -> response(result)
    end
  end

  defp put(url, data) do
    case Tesla.put(client(), url, data) do
      {:ok, result} -> response(result)
    end
  end

  defp delete(url, data \\ %{}) do
    case Tesla.delete(client(), url, body: data) do
      {:ok, result} -> response(result)
    end
  end

  defp response(result) do
    error_codes = [400, 403, 404]

    if Enum.member?(error_codes, result.status),
      do: {:error, result.body["message"]},
      else: {:ok, result.body}
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
