defmodule ExBanking.Utils do
  @max_process_load_in_queue 9

  @spec get_username(user :: String.t()) :: {:ok, atom()} | {:error, :wrong_arguments}
  def get_username(user) do
    if String.valid?(user) do
      username = String.to_atom(user)
      {:ok, username}
    else
      {:error, :wrong_arguments}
    end
  end

  @spec get_user_pid(user :: String.t()) :: {:ok, pid} | {:error, :user_does_not_exist}
  def get_user_pid(user) do
    case get_username(user) do
      {:ok, username} ->
        case Process.whereis(username) do
          nil -> {:error, :user_does_not_exist}
          pid -> {:ok, pid}
        end

      _ ->
        {:error, :user_does_not_exist}
    end
  end

  @spec get_decimal(amount :: term()) :: {:ok, Decimal.t()} | {:error | :wrong_arguments}
  def get_decimal(amount) do
    case Decimal.cast(amount) do
      {:ok, new_amount} ->
        case Decimal.positive?(new_amount) do
          false ->
            {:error, :wrong_arguments}

          true ->
            {:ok, Decimal.round(new_amount, 2)}
        end
    end
  end

  @spec is_process_overload?(pid :: pid) :: true | false
  def is_process_overload?(pid) do
    {:message_queue_len, item_count} = Process.info(pid, :message_queue_len)
    @max_process_load_in_queue <= item_count
  end
end
