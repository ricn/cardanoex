defmodule Cardano.Backend do
  def create_wallet(name, mnemonic_sentence, passphrase, mnemonic_second_factor, address_pool_gap) do
    data = %{name: name, mnemonic_sentence: mnemonic_sentence, passphrase: passphrase, address_pool_gap: address_pool_gap}

    if mnemonic_second_factor != nil,
      do: Map.put_new(data, :mnemonic_second_factor, mnemonic_second_factor)

    case Tesla.post(client(), "/wallets", data) do
      {:ok, result} -> response(result)
    end
  end

  defp response(result) do
    if result.status == 400 do
      {:error, result.body["message"]}
    else
      {:ok, result.body}
    end
  end

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, "http://localhost:8090/v2"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
