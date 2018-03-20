defmodule BattleshipServer.Registry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, _} = Registry.start_link(keys: :duplicate, name: Registry.BattleshipPubSub, partitions: System.schedulers_online)
    {:ok, nil}
  end

  def register(topic) do
    {:ok, _} = Registry.register(Registry.BattleshipPubSub, topic, [])
  end

  def dispatch(topic, message) do
    Registry.dispatch(Registry.BattleshipPubSub, topic, 
    fn entries -> for {pid, _} <- entries,
    do: send(pid, message) 
    end)
  end



end