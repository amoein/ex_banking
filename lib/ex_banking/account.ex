defmodule ExBanking.Account do
  use GenServer

  @spec deposit(use_pid :: pid, amount :: Decimal.t(), currency :: String.t()) ::
          {:ok, new_balance :: float()} | :error
  def deposit(user_pid, amount, currency) do
    GenServer.call(user_pid, {:deposit, amount, currency})
  end

  @spec withdraw(use_pid :: pid, amount :: Decimal.t(), currency :: String.t()) ::
          {:ok, new_balance :: float()} | :error | {:error, :not_enough_money}
  def withdraw(user_pid, amount, currency) do
    GenServer.call(user_pid, {:withdraw, amount, currency})
  end

  @spec start(username :: atom) :: {:ok, pid} | :error
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
        {:reply, {:ok, Decimal.to_float(new_balance)}, %{state | currency => new_balance}}
    end
  end

  def handle_call({:withdraw, amount, currency}, _, state) do
    case Map.get(state, currency) do
      nil ->
        {:reply, {:error, :not_enough_money}, state}

      balance ->
        if amount > balance do
          {:reply, {:error, :not_enough_money}, state}
        else
          new_balance = Decimal.sub(balance, amount)
          {:reply, {:ok, Decimal.to_float(new_balance)}, %{state | currency => new_balance}}
        end
    end
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
