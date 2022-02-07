defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create user" do
    assert ExBanking.create_user("m") == :ok
  end

  test "create user and deposit" do
    assert ExBanking.create_user("m1") == :ok

    res = ExBanking.deposit("m1" , 10, "d")
    IO.inspect res
    assert res === {:ok, 10.00}

    assert ExBanking.deposit("m1" , 100.01 , "d") == {:ok, 110.01}

    assert ExBanking.deposit("m1" , 50.2 , "d") == {:ok, 160.21}

    assert ExBanking.deposit("m1" , -43.2 , "d") ==  {:error, :wrong_arguments}

  end

end
