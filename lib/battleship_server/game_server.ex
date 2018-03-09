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


  def join_player(username, client_node, state) do

    if is_unique?(state, username) do
      case Map.get(state, :wait_list) do
        {nil, nil}                      ->    Process.send({:client, client_node}, :alone, [])
                                                  %{state | wait_list: {username, client_node}}
        {_, first_client_node}   ->    {:ok, new_game_pid, state}  = create_new_game(state, {username, client_node})
                                                    Process.send({:client, first_client_node}, {:game_created, new_game_pid}, [])
                                                    Process.send({:client, client_node}, {:game_created, new_game_pid}, [])
                                                  state
      end

    else
      Process.send({:client, client_node}, :not_unique, [])
    end

  end


  def handle_info({:join_game, username, client_node, client_pid},  state) do
    IO.puts "#{username} has joined!"
    state = join_player(username, client_node, state)
    {:noreply, state}
  end


  # def join_player(username, client_node, client_pid) do
  #   case GenServer.call(:game_server, {:join, username}, 50000000) do
  #      :alone -> Process.send({:client, client_node}, :alone, [])
  #       #IO.puts("#{username} is waiting for other player")

  #     :not_unique ->  Process.send({:client, client_node}, :not_unique, [])
  #       #IO.puts("username: #{username} already exists ")

  #     :error_new_game ->  Process.send({:client, client_node}, :error, [])
  #       #IO.puts("error at game creation")

  #     {:ok, new_game_pid} -> Process.send({:client, client_node}, {:game_created, new_game_pid}, [])
  #       #IO.puts("game created")
  #       #new_game_pid

  #   end
  # end
  # def handle_call({:join, username}, _from, state) do
  #   with true <- is_unique?(state, username) do
  #     case Map.get(state, :wait_list) do
  #       nil -> {:reply, :alone, %{state | wait_list: username}}
  #       _ -> create_new_game(state, username)
  #     end
  #   else
  #     false -> {:reply, :not_unique, state}
  #   end
  # end

  def is_unique?(state, username) do

    state |> IO.inspect
    username |> IO.inspect
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

      state = %{state | wait_list: {nil, nil}, games: Map.put(state.games, new_game_id, new_game)}
      {:ok, new_game_pid, state}
    end
  end
end
