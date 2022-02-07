defmodule ExBanking do
  alias ExBanking.{Account, Utils}

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}

  def create_user(user) do
    case Utils.get_username(user) do
      {:ok, username} ->
        if is_nil(Process.whereis(username)) do
          case Account.start(username) do
            {:ok, _pid} ->
              :ok

            _ ->
              {:error, :wrong_arguments}
          end
        else
          {:error, :user_already_exists}
        end

      _ ->
        {:error, :wrong_arguments}
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) when is_number(amount) do
    case Utils.get_decimal(amount) do
      {:ok, valid_amount} ->
        case Utils.get_user_pid(user) do
          {:error, :user_does_not_exist} ->
            {:error, :user_does_not_exist}

          {:ok, pid} ->
            if Utils.is_process_overload?(pid) do
              {:error, :too_many_requests_to_user}
            else
              case Account.deposit(pid, valid_amount, currency) do
                {:ok, new_balance} -> {:ok, new_balance}
                _ -> {:error, :wrong_arguments}
              end
            end
        end

      _ ->
        {:error, :wrong_arguments}
    end
  end

  def deposit(_, _, _), do: {:error, :wrong_arguments}

  @spec withdraw(user :: String.t(), amount :: Number.t(), currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    :ok
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number()}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    :ok
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number(), to_user_balance :: number()}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}

  def send(from_user, to_user, amount, currency) do
    :ok
  end
end
