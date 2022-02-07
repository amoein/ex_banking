defmodule ExBanking.Account do
  use GenServer

  def deposit(user_pid, amount, currency) do
    GenServer.call(user_pid, {:deposit, amount, currency})
  end

  @spec start(user :: atom) :: {:ok, pid} | :error
  def start(username) do
    GenServer.start(__MODULE__, [], name: username)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:deposit, amount, currency}, _, state) do
    case Map.get(state, currency) do
      nil ->
        new_state = Map.put_new(state, currency, amount)
        {:reply, {:ok, Decimal.to_float(amount)}, new_state}

      balance ->
        new_balance = Decimal.add(balance, amount)
        IO.inspect(new_balance)
        {:reply, {:ok, Decimal.to_float(new_balance)}, %{state | currency => new_balance}}
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
