defmodule BattleshipServer.Store do


  def new_game(new_game_id, pl1, pl2) do
    query = "INSERT INTO game VALUES (#{new_game_id},'#{pl1}', '#{pl2}', null, '#{DateTime.utc_now()}', null)"
    BattleshipServer.Repo.query query 
  end

  def winner(game, game_winner) do
    query = "UPDATE game SET winner = '#{game_winner}', end_date = '#{DateTime.utc_now()}' WHERE game_id = #{game}"
    BattleshipServer.Repo.query query
  end
end