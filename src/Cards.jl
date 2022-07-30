# Module for The King is Dead bot
# This houses all of the cards

# Swap 2 followers between 2 regions
# This is the Manoeuvre action
function get_manoueuvre_options(board::Board; input_function=readline,
    allow_same_followers=true)
    # First get all valid combinations
    # Get all pairs of regions to swap between
    options = Vector{Tuple{Tuple{Region, String}, Tuple{Region, String}}}()
    # println("These are the options available when playing the manoueuvre action: ")
    for (i1, r1) in enumerate(board.unresolved_regions)
        for (i2, r2) in enumerate(board.unresolved_regions)
            if i2 > i1
                # println(r1.name, " - ", r2.name)
                # Get all possible followers to swap between
                for (f_name1, f_num1) in r1.followers, (f_name2, f_num2) in r2.followers
                    if (f_num1 > 0) & (f_num2 > 0)
                        if allow_same_followers
                            push!(options, ((r1, f_name1), (r2, f_name2)))
                        elseif (f_name1 != f_name2)
                            push!(options, ((r1, f_name1), (r2, f_name2)))
                        end
                    end
                end
            end
        end
    end

    return options;
end

function play_manoueuvre(board::Board, argument)
    argument1 = argument[1], argument2 = argument[2]
    return play_manoueuvre(board, argument1, argument2)
end

function play_manoueuvre(board::Board, argument1, argument2)
    board = deepcopy(board)
    region_1 = argument1[1].name
    follower_1 = argument1[2]
    region_2 = argument2[1].name
    follower_2 = argument2[2]
    # First check if region 1 has a follower 1
    @toggled_assert board.regions[region_1].followers[follower_1] > 0
    @toggled_assert board.regions[region_2].followers[follower_2] > 0
    board.regions[region_1].followers[follower_1] -= 1
    board.regions[region_1].followers[follower_2] += 1
    board.regions[region_2].followers[follower_1] += 1
    board.regions[region_2].followers[follower_2] -= 1
    return board
end

function play_manoueuvre!(board::Board, (region1, faction1)::Tuple{String, String},
                    (region2, faction2)::Tuple{String, String},
                    input_function=readline)
    # First get all valid combinations
    # Get all pairs of regions to swap between
    # combinations = Combinatorics.combinations(board.unresolved_regions, 2)
    # for ((r1, r2) in combinations)
    #     println(r1.name, " - ", r2.name)
    #     for (f_name1, f_num1) in r1.followers
    #         if f_num1 > 0
    #             for (f_name2, f_num2) in r2.followers
    #                 if f_num2 > 0
    #                 end
    #             end
    #         end
    #     end
    #
    # end
    for (i1, r1) in enumerate(board.unresolved_regions)
        for (i2, r2) in enumerate(board.unresolved_regions)
            if i2 > i1
                println(r1.name, " - ", r2.name)
                # Get all possible followers to swap between
                for (f_name1, f_num1) in r1.followers
                    if f_num1 > 0
                        for (f_name2, f_num2) in r2.followers
                            if f_num2 > 0
                                new_board = deepcopy(board)
                                push!(possible_boards, new_board)
                                swap_followers!(new_board,
                                (r1.name, f_name1), (r2.name, f_name2))
                            end
                        end
                    end
                end
            end
        end
    end

    # for r in board.unresolved_regions
    #     if r.name == region1
    #         if r.followers[faction1] == 0
    #             error("Trying to take a follower from a region where that faction is not present\n",
    #             "Tried to take a(n) ", faction, " follower from ", region)
    #         end
    #         r.followers[faction1] -= 1
    #         r.followers[faction2] += 1
    #     end
    #     if r.name == region2
    #         if r.followers[faction2] == 0
    #             error("Trying to take a follower from a region where that faction is not present\n",
    #             "Tried to take a(n) ", faction, " follower from ", region)
    #         end
    #         r.followers[faction2] -= 1
    #         r.followers[faction1] += 1
    #     end
    # end
    return input_function()
end

function outmanoeuvre!(board::Board, (region1, faction1)::Tuple{String, String},
                    (region2, faction2)::Tuple{String, String})
    for r in board.unresolved_regions
        if r.name == region1
            if r.followers[faction1] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            global remove_followers = min(2, r.followers[faction1])
            r.followers[faction1] -= remove_followers
            r.followers[faction2] += 1
        end
        if r.name == region2
            if r.followers[faction2] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            r.followers[faction2] -= 1
            r.followers[faction1] += remove_followers
        end
    end
end

CARD_MAPPING = Dict(
    "manoueuvre" => (get_manoueuvre_options, play_manoueuvre),
    "take follower" => (get_follower_options, take_follower)
)
