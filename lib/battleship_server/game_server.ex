defmodule Game.Server do
  use GenServer

  defstruct [:wait_list, :games]

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: :game_server)
  end

  def init(_) do
    # games : %{ game_id => %{game_pid: nil, game_id: new_game_id, player1: state.wait_list, player2: username, winner: nil}}
    Node.set_cookie(Node.self, :"test")
    state = %Game.Server{wait_list: {nil, nil}, games: Map.new()}

    

    {:ok, state}
  end


  def join_player(username, client_pid, state) do
    case is_unique?(state, username) do
      true  ->  check_for_pair( username, client_pid, state)
      false ->  Server.Protocol.send_to(client_pid, :not_unique)
                IO.puts "Connection denied: not unique username"
    end
  end

  def check_for_pair(username, client_pid, state)  do

    case Map.get(state, :wait_list) do
      {nil, nil}                                  ->    Server.Protocol.send_to(client_pid, :alone)
                                                        IO.puts "#{username} connected successfully"
                                                        %{state | wait_list: {username, client_pid}}


      {first_client_username, first_client_pid}   ->   {:ok, new_game_pid, state}  = create_new_game(state, {username, client_pid})
                                                        IO.puts "#{username} connected successfully"
                                                        Server.Protocol.send_to(first_client_pid, client_pid, {:game_created, new_game_pid})
                                                        IO.puts "#{username} is playing with #{first_client_username} at the battle with ID: #{inspect new_game_pid}"
                                                        state
    end
  end

  def handle_info({:join_game, username, client_node, client_pid},  state) do
    IO.puts "#{username} from client_pid: #{inspect client_pid}} is trying to connect!"
    state = join_player(username, client_pid, state)
    {:noreply, state}
  end

  def is_unique?(state, username) do

    unique_at_games =
      Enum.any?(state.games, fn {_, value} ->
        Map.get(value, :player1) == username or Map.get(value, :player2) == username
      end)

    case unique_at_games or elem(state.wait_list, 0) == username do
      true -> false
      false -> true
    end
  end

  # games : %{ game_id => %{game_pid: nil, game_id: new_game_id, player1: state.wait_list, player2: username, winner: nil}}
  def create_new_game(state, client_data) do
    with new_game_id = :erlang.unique_integer(),
         new_game_data = %{game_id: new_game_id, player1: state.wait_list, player2: client_data},
         {:ok, new_game_pid} <- Battle.Supervisor.new_game(new_game_data) do

          new_game = %{
        game_pid: new_game_pid,
        game_id: new_game_id,
        player1: state.wait_list,
        player2: client_data,
        winner: nil
      }


      BattleshipServer.Registry.dispatch("game_start_stop",  {:game_created, new_game_id, elem(state.wait_list, 0), elem(client_data, 0)})

      state = %{state | wait_list: {nil, nil}, games: Map.put(state.games, new_game_id, new_game)}
      {:ok, new_game_pid, state}
    end
  end
end
