defmodule ExBanking.Account do
  use GenServer
  @max_process_load_in_queue 9

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

  @spec get_balance(use_pid :: pid, currency :: String.t()) ::
          {:ok, new_balance :: float()} | :error
  def get_balance(user_pid, currency) do
    GenServer.call(user_pid, {:get_balance, currency})
  end

  @spec send(
          pid_sender :: pid,
          pid_receiver :: pid,
          amount :: Decimal.t(),
          currency :: String.t()
        ) ::
          {:ok, new_balance :: float()}
          | :error
          | {:error, :not_enough_money}
          | {:error, :too_many_requests_to_receiver}
  def send(pid_sender, pid_receiver, amount, currency) do
    GenServer.call(pid_sender, {:send, pid_receiver, amount, currency})
  end

  @spec is_process_overload?(pid :: pid) :: true | false
  def is_process_overload?(pid) do
    {:ok, item_count} = GenServer.call(pid, :queue_len)
    @max_process_load_in_queue <= item_count
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

  def handle_call({:get_balance, currency}, _, state) do
    balance =
      case Map.get(state, currency) do
        nil ->
          {:ok, balance} = Decimal.cast(0.00)
          balance

        balance ->
          balance
      end

    {:reply, {:ok, Decimal.to_float(balance)}, state}
  end

  def handle_call({:send, pid_receiver, amount, currency}, _, state) do
    case Map.get(state, currency) do
      nil ->
        {:reply, {:error, :not_enough_money}, state}

      balance ->
        if amount > balance do
          {:reply, {:error, :not_enough_money}, state}
        else
          if is_process_overload?(pid_receiver) do
            {:reply, {:error, :too_many_requests_to_receiver}, state}
          else
            case deposit(pid_receiver, amount, currency) do
              {:ok, receiver_new_balance} ->
                new_balance = Decimal.sub(balance, amount)

                {:reply, {:ok, Decimal.to_float(new_balance), receiver_new_balance},
                 %{state | currency => new_balance}}

              _ ->
                {:reply, :error, state}
            end
          end
        end
    end
  end

  def handle_call(:queue_len, _, state) do
    {:message_queue_len, item_count} = Process.info(self(), :message_queue_len)
    {:reply, {:ok, item_count}, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
