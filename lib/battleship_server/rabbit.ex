defmodule BattleshipServer.Rabbit do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :rabbit)
  end

  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Exchange.declare(channel, "game_server", :topic)
    {:ok, channel}
  end

  def pub(exchange, topic, message) do
    GenServer.cast(:rabbit, {:pub, exchange, topic, message})
  end

  def handle_cast({:pub, exchange, topic, message}, state) do
    AMQP.Basic.publish(state, exchange, topic, message)
    {:noreply, state}
  end
end
