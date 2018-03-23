defmodule BattleshipServer.Store do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Exchange.declare(channel, "game_server", :topic)
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
    AMQP.Queue.bind(channel, queue_name, "game_server", routing_key: "*.store")
    AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
    {:ok, nil}
  end

  def handle_cast({:start, channel}, _state) do
    wait_for_messages(channel)
    {:noreply, nil}
  end

  def handle_info({:basic_consume_ok, _}, _), do: {:noreply, nil}

  def wait_for_messages(channel) do
    IO.puts("Waiting for messages")

    receive do
      {:basic_deliver, payload, _meta} ->
        case Poison.decode!(payload) do
          %{"player_2" => pl2, "player_1" => pl1, "game_id" => game_id} ->
            new_game(game_id, pl1, pl2)

          %{"Winner" => game_winner, "game_id" => game} ->
            winner(game, game_winner)
        end

        wait_for_messages(channel)
    end
  end

  def new_game(new_game_id, pl1, pl2) do
    %Battleshipserver.Db.Game{
      game_id: new_game_id,
      player1_username: pl1,
      player2_username: pl2,
      start_date: DateTime.utc_now()
    }
    |> Battleshipserver.Db.Game.changeset()
    |> BattleshipServer.Repo.insert!()
  end

  def winner(game, game_winner) do
    g =
      BattleshipServer.Repo.get_by(Battleshipserver.Db.Game, game_id: game)
      |> Ecto.Changeset.change(end_date: DateTime.utc_now(), winner: game_winner)
      |> BattleshipServer.Repo.update()

    case g do
      {:ok, struct} -> IO.puts("Updated with success")
      {:error, changeset} -> IO.puts("Something went wrong")
    end
  end
end
