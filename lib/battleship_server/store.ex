defmodule BattleshipServer.Store do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do


    {:ok, _} = BattleshipServer.Registry.register("game_start_stop")

    {:ok, nil}
  end

def handle_info({:game_created, new_game_id, pl1, pl2}, _state) do
  new_game(new_game_id, pl1, pl2)
  {:noreply, nil}
end

def handle_info({:game_ended_with_winner, game_id, winner_username}, _state) do
  winner(game_id, winner_username)
  {:noreply, nil}
end


  def new_game(new_game_id, pl1, pl2) do
    %Battleshipserver.Db.Game{ game_id: new_game_id,
                                player1_username: pl1,
                                player2_username: pl2,
                                start_date: DateTime.utc_now()
    }
    |>Battleshipserver.Db.Game.changeset
    |>BattleshipServer.Repo.insert!

    # query = "INSERT INTO game VALUES (#{new_game_id},'#{pl1}', '#{pl2}', null, '#{DateTime.utc_now()}', null)"
    # BattleshipServer.Repo.query query
  end

  def winner(game, game_winner) do

    g = BattleshipServer.Repo.get_by(Battleshipserver.Db.Game, game_id: game)
    |> Ecto.Changeset.change(end_date: DateTime.utc_now(), winner: game_winner )
    |> BattleshipServer.Repo.update
    case g do
      {:ok, struct}       -> IO.puts "Updated with success"
      {:error, changeset} -> IO.puts "Something went wrong"
    end

    # query = from "game", where: [game_id: '#{game_winner}'], update: [set: [end_date: '#{DateTime.utc_now()}']]
    # MyApp.Repo.update_all(query)
    # query = "UPDATE game SET winner = '#{game_winner}', end_date = '#{DateTime.utc_now()}' WHERE game_id = #{game}"
    # BattleshipServer.Repo.query query
  end
end
