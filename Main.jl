# Module for The King is Dead bot
# This houses all of the types

using DataFrames
using Random
using YAML
Random.seed!(100)

include("src/Types.jl")
include("src/Funcs.jl")
include("src/Display.jl")

# inputs = YAML.load_file("inputs.yaml")
inputs = YAML.load_file("Simple inputs.yaml")

court_size = 2
region_size = 4
faction_names = inputs["faction_names"]
region_names = inputs["region_names"]
player_names = inputs["player_names"]

supply = Supply(faction_names)

# Give each homebase region the 2 followers it needs
regions = Array{Region}(undef, 0)
for (r, r_adj) in region_names
    followers = Dict(k=>0 for k in keys(faction_names))
    size = 0
    for (f, starting_region) in faction_names
        if r == starting_region
            followers[f] += 2
            size = 2
            supply.followers[f] -= 2 # Reduce the supply
        end
    end
    push!(regions, Region(r, followers, size, r_adj))
end

# Initialise the players
players = Array{Player}(undef, 0)
for name in player_names
    push!(players, Player(name))
end

initialise_player_courts!(players, supply)

# Initialise the board
board = Board(regions, supply)
initialise_board!(board, supply)

println(board)
println(board.supply)
resolve_region!(board, "Essex")
println(board.supply)
