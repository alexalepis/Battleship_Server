defmodule BattleshipServer.Store do

 def new_game(new_game_id, pl1, pl2) do
    %Battleshipserver.Db.Game{ game_id: new_game_id,
                                player1_username: pl1,
                                player2_username: pl2,
                                start_date: DateTime.utc_now()
    }
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
