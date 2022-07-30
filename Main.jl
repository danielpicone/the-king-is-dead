# Module for The King is Dead bot
# This houses all of the types

using DataFrames
using Random
using YAML
using ToggleableAsserts
Random.seed!(100)

include("src/Types.jl")
include("src/Funcs.jl")
include("src/Cards.jl")
include("src/Display.jl")

# inputs = YAML.load_file("inputs.yaml", dicttype=Dict{String, Union{Int64, Any}})
inputs = YAML.load_file("Simple inputs.yaml", dicttype=Dict{String, Union{Int64, Any}})

court_size = 2
region_size = 4
faction_names = inputs["faction_names"]
region_names = inputs["region_names"]
player_names = inputs["player_names"]
card_names = inputs["card_names"]

# Set up the regions
regions = Array{Region}(undef, 0)
for (r, r_adj) in region_names
    followers = Dict(k=>0 for k in keys(faction_names))
    size = 0
    push!(regions, Region(r, followers, size, r_adj))
end

# Initialise the players
players = Array{Player}(undef, 0)
for name in player_names
    push!(players, Player(name))
end

# Initialise cards
cards = Array{Card}(undef, 0)
for (name, card) in card_names
    push!(cards, Card(name, card))
end



# Initialise the board
board = Board(regions, players)
# initialise_player_courts!(players, board)
initialise_board!(board)
GAME = Game(board, Vector{Action}())

println(board)
# println(board.supply)
# resolve_region!(board, "Essex")
# println(board.supply)


# Ask player 1 which card they would like to use

# Then get all the options they may do with that card and their response
player_action = ask_for_action(board.players[1], "manoueuvre")
# Then ask which follower they would like to take and their response
player_action = ask_for_action(board.players[1], "take follower")


# Work out ALL possible board states after using a card
# card = cards[7]
# num_reg_to_check = 3
# possible_boards = Board[]
# num_reg_to_check = min(num_reg_to_check, length(board.unresolved_regions))
# if card.type == "followers"
#     # First do Assemble
#     if (card.adjacent == false) & isnothing(card.swap)
#         allocations = Dict[]
#         let iteration_counter = 1
#             for r in board.unresolved_regions[1:num_reg_to_check]
#                 for r2 in board.unresolved_regions[1:num_reg_to_check]
#                     for r3 in board.unresolved_regions[1:num_reg_to_check]
#                         push!(possible_boards, deepcopy(board))
#                         allocation = Dict("English" => r.name,
#                              "Welsh" => r2.name,
#                              "Scottish" => r3.name)
#                         push!(allocations, allocation)
#                         for p in allocation
#                             place_follower!(possible_boards[iteration_counter], p)
#                         end
#                         iteration_counter += 1
#                     end
#                 end
#             end
#         end
#     elseif (card.adjacent == false) & !isnothing(card.swap)
#         # Now do Manoeuvre
#         # Get all pairs of regions to swap between
#         for (i1, r1) in enumerate(board.unresolved_regions)
#             for (i2, r2) in enumerate(board.unresolved_regions)
#                 if i2 > i1
#                     println(r1.name, " - ", r2.name)
#                     # Get all possible followers to swap between
#                     for (f_name1, f_num1) in r1.followers
#                         if f_num1 > 0
#                             for (f_name2, f_num2) in r2.followers
#                                 if f_num2 > 0
#                                     new_board = deepcopy(board)
#                                     push!(possible_boards, new_board)
#                                     swap_followers!(new_board,
#                                     (r1.name, f_name1), (r2.name, f_name2))
#                                 end
#                             end
#                         end
#                     end
#                 end
#             end
#         end
#     elseif isnothing(card.swap)
#         # Now do Faction support
#         # Determine all possible regions if an adjacent constraint is present
#         # and followers are being placed
#         # First work out which regions are controlled by the faction specified
#         controlled_regions = [r.name for r in board.regions if r.controller == card.adjacent]
#         possible_regions = []
#         for r in board.unresolved_regions
#             for adj in r.adjacent
#                 if adj in controlled_regions
#                     push!(possible_regions, r.name)
#                 end
#             end
#         end
#         for r_name in possible_regions
#             new_board = deepcopy(board)
#             for (f_name, f_num) in card.place
#                 println(f_name)
#                 for n in 1:f_num
#                     place_follower!(new_board, r_name, f_name)
#                 end
#             end
#             push!(possible_boards, new_board)
#         end
#     else
#         # Lastly do Outmanoeuvre
#         # Determine all possible regions if an adjacent constraint is present
#         # and followers are being swapped
#         for (i1, r1) in enumerate(board.unresolved_regions)
#             for (i2, r2) in enumerate(board.unresolved_regions)
#                 if r2.name in r1.adjacent
#                     # println(r1.name, " - ", r2.name)
#                     # Get all possible followers to swap between
#                     for (f_name1, f_num1) in r1.followers
#                         if f_num1 > 1
#                             for (f_name2, f_num2) in r2.followers
#                                 if f_num2 > 0
#                                     new_board = deepcopy(board)
#                                     # println("Swapping 2 ", f_name1, " from ", r1.name, " with 1 ", f_name2, " from ",
#                                     # r2.name)
#                                     push!(possible_boards, new_board)
#                                     outmanoeuvre!(new_board,
#                                     (r1.name, f_name1), (r2.name, f_name2))
#                                 end
#                             end
#                         end
#                     end
#                 end
#             end
#         end
#     end
# elseif card.type == "cards"
#     # Do the negotiate card
#
# end
#
# # For every single board state created by playing a card,
# # work out every single follower removal combination
# player = players[1]
# possible_boards_after_rem = Board[]
# # possible_board = possible_boards[1]
# for possible_board in possible_boards
#     possible_removals = Pair[]
#     for r in possible_board.unresolved_regions
#         for (f_name,f_num) in r.followers
#             if f_num > 0
#                 take_pair = r.name=>f_name
#                 push!(possible_removals, r.name=>f_name)
#                 board_after_rem = deepcopy(possible_board)
#                 take_follower!(board_after_rem, r.name, f_name)
#                 # println(evaluate_resolved_board(board_after_rem))
#                 push!(possible_boards_after_rem, board_after_rem)
#             end
#         end
#     end
# end
