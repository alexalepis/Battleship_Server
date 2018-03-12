defmodule Battle do
  use GenServer

  def start_link(game_data) do
    GenServer.start_link(__MODULE__, game_data)
  end

  def init(game_data) do
    data = data_init(game_data)
    {:ok, data}
  end

  def data_init(%{game_id: new_game_id, player1: {pl1, pl1_node}, player2: {pl2, pl2_node}}) do

     game =
      Game.new(new_game_id, Game.Settings.new())
      |> Game.add_player(pl1_node, pl1)
      |> Game.add_player(pl2_node, pl2)

      player1 = Player.place_random(game.current_player)
      player2 = Player.place_random(game.enemy_player)

      Server.Protocol.send_to(player1.id, {:init_data, player1.my_board})
      Server.Protocol.send_to(player2.id, {:init_data, player2.my_board})

      %{game | current_player: player1, enemy_player: player2}
  end

  def next_move(game, x, y) do
    {status, new_game, message} = Game.make_move(game, x, y)
    case {status, new_game, message} do
      {:error, _, :game_ended}    ->  Server.Protocol.send_to(new_game.current_player.id, new_game.enemy_player.id, message)
      {:error, _, :out_of_bounds} ->  Server.Protocol.send_to(new_game.current_player.id, message)
      {:error, _, :already_shot}  ->  Server.Protocol.send_to(new_game.current_player.id, message)
      {:ok, _, :winner}           ->  Server.Protocol.send_to(new_game.current_player.id, new_game.enemy_player.id, {message, new_game.enemy_player.name})
      {:ok, _, :hit}              ->  Server.Protocol.send_to(new_game.enemy_player.id, {message, new_game.enemy_player.name, new_game.enemy_player.shot_board})
                                      Server.Protocol.send_to(new_game.current_player.id, {message, new_game.enemy_player.name, new_game.current_player.my_board})
                                      Server.Protocol.send_to(new_game.current_player.id, :your_turn)

      {:ok, _, :miss}             ->  merged_map = Map.merge(new_game.current_player.my_board.map, new_game.enemy_player.shot_board.map)
                                      merged_board = %Board{map: merged_map, n: new_game.current_player.my_board.n}
                                      Server.Protocol.send_to(new_game.enemy_player.id, {message, new_game.enemy_player.name, new_game.enemy_player.shot_board})
                                      Server.Protocol.send_to(new_game.current_player.id, {message, new_game.enemy_player.name, merged_board})
                                      Server.Protocol.send_to(new_game.current_player.id, :your_turn)

    end

    new_game

  end



  def handle_info({:make_move, x, y, caller_id},  state) do

    case state.current_player.id == caller_id do
      true -> state = next_move(state, x, y)
      false -> Server.Protocol.send_to(caller_id, :not_your_turn)
    end

    {:noreply, state}
  end

end
