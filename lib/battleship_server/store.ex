defmodule BattleshipServer.Store do

  def new_game(new_game_id, pl1, pl2) do
     BattleshipServer.Repo.query("INSERT INTO game VALUES (#{new_game_id},'#{pl1}', '#{pl2}', null)")    
  end

  def winner(game, game_winner) do
    BattleshipServer.Repo.query("UPDATE game SET winner = '#{game_winner}' WHERE game_id = #{game}")
  end
end