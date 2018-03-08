defmodule Battle.Supervisor do
    use DynamicSupervisor

    def start_link(_arg) do
        DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__) 
    end

    def new_game(game_data) do
        DynamicSupervisor.start_child(__MODULE__ ,{Battle, game_data})
    end


    def init(_) do
        DynamicSupervisor.init(strategy: :one_for_one)
    end
end