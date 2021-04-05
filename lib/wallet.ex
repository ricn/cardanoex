defmodule Cardano.Wallet do
  defstruct id: nil,
            name: nil,
            address_pool_gap: nil,
            assets: [],
            balance: %{},
            delegation: %{},
            passphrase: %{},
            tip: %{},
            state: %{}

  alias Cardano.Backend

  def keys_to_atom(map) do
    Map.new(
     map,
     fn {k, v} ->
       v2 = cond do
         is_map(v) -> keys_to_atom(v)
         v in [[nil], nil] -> nil
         is_list(v) -> Enum.map(v, fn o -> keys_to_atom(o) end)
         true -> v
       end
       {String.to_atom("#{k}"), v2}
     end
    )
   end

  def create_wallet(options \\ []) do
    default = [
      name: nil,
      mnemonic_sentence: nil,
      passphrase: nil,
      mnemonic_second_factor: nil,
      address_pool_gap: 20
    ]

    opts = Enum.into(Keyword.merge(default, options), %{})

    result = Backend.create_wallet(
      opts.name,
      opts.mnemonic_sentence,
      opts.passphrase,
      opts.mnemonic_second_factor,
      opts.address_pool_gap
    )

    case result do
      {:ok, wallet} -> {:ok, keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  def fetch(id) do
    case Backend.fetch_wallet(id) do
      {:ok, wallet} -> {:ok, keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  def list() do
    case Backend.list_wallets() do
      {:ok, wallets} -> {:ok, Enum.map(wallets, fn(w) -> keys_to_atom(w) end)}
      {:error, message} -> {:error, message}
    end
  end

  def delete(id) do
    case Backend.delete_wallet(id) do
      {:ok, _} -> {:ok, :no_content}
      {:error, message} -> {:error, message}
    end
  end

  def fetch_utxo_stats(id) do
    case Backend.fetch_wallet_utxo_stats(id) do
      {:ok, utxo_stats} -> {:ok, keys_to_atom(utxo_stats)}
      {:error, message} -> {:error, message}
    end
  end

  def update(id, name) do
    case Backend.update_wallet_metadata(id, name) do
      {:ok, wallet} -> {:ok, keys_to_atom(wallet)}
      {:error, message} -> {:error, message}
    end
  end

  def update_passphrase(id, old_passphrase, new_passphrase) do
    case Backend.update_wallet_passphrase(id, old_passphrase, new_passphrase) do
      {:ok, _} -> {:ok, :no_content}
      {:error, message} -> {:error, message}
    end
  end
end
