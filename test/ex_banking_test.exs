defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create user" do
    assert ExBanking.create_user("m") == :ok
  end

  test "create user and deposit" do
    assert ExBanking.create_user("m1") == :ok

    assert ExBanking.deposit("m2", 10, "d") === {:error, :user_does_not_exist}

    assert ExBanking.deposit("m1", 10, "d") === {:ok, 10.00}

    assert ExBanking.deposit("m1", 100.01, "d") == {:ok, 110.01}

    assert ExBanking.deposit("m1", 50.2, "d") == {:ok, 160.21}

    assert ExBanking.deposit("m1", -43.2, "d") == {:error, :wrong_arguments}
  end

  test "create user and deposit and withdraw" do
    assert ExBanking.create_user("m2") == :ok

    assert ExBanking.deposit("m2", 1100.54, "d") === {:ok, 1100.54}

    assert ExBanking.deposit("m2", 634.54, "e") === {:ok, 634.54}

    assert ExBanking.withdraw("m2", 100.01, "d") == {:ok, 1000.53}

    assert ExBanking.withdraw("m2", 9800.01, "d") == {:error, :not_enough_money}

    assert ExBanking.withdraw("m2", 800.01, "e") == {:error, :not_enough_money}
  end

  test "create user and deposit and get_balance" do
    assert ExBanking.create_user("m3") == :ok

    assert ExBanking.get_balance("m3", "d") === {:ok, 0.00}

    assert ExBanking.deposit("m3", 1100.54, "d") === {:ok, 1100.54}

    assert ExBanking.get_balance("m3", "d") === {:ok, 1100.54}
  end
end
