defmodule BattleshipServerTest do
  use ExUnit.Case
  doctest BattleshipServer

  test "greets the world" do
    assert BattleshipServer.hello() == :world
  end
end
