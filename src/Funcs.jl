# Module for The King is Dead bot
# This houses all of the functions

function action(player, name::String, argument::Tuple)
    Action(player, name, CARD_MAPPING[name][2], argument)
end

function ask_for_action(player, card_name; game = GAME)
    func = CARD_MAPPING[card_name][1]
    options = func(game.board)
    for (i, option) in enumerate(options)
        println(i, ": ", option)
    end
    chosen_play = parse(Int64, readline())

    player_action = action(player, card_name, options[chosen_play])
    push!(game.actions, player_action)
    player_action.action_fun(game.board, player_action.argument...)
    return player_action
end

function random_pick_from_supply(board::Board)
    supply_array = Array{String}(undef, 0)
    for (f_name, f_num) in board.supply
        append!(supply_array, repeat([f_name], f_num))
    end
    pick = supply_array[rand(1:length(supply_array))]
    return pick
end

function initialise_player_courts!(players::Array{Player}, board::Board)
    for player in players
        while player.court_size < court_size
            pick = random_pick_from_supply(board)
            player.court[pick] += 1
            player.court_size += 1
            board.supply[pick] -= 1
        end
    end
end

function initialise_board!(board::Board)
    # First make the players' courts
    for player in board.players
        while player.court_size < court_size
            pick = random_pick_from_supply(board)
            player.court[pick] += 1
            player.court_size += 1
            board.supply[pick] -= 1
        end
    end
    # Then put followers in home bases
    for region in board.regions
        for (f, starting_region) in faction_names
            if region.name == starting_region
                region.followers[f] += 2
                region.size = 2
                board.supply[f] -= 2 # Reduce the supply
                for r in board.unresolved_regions
                    if r.name == starting_region
                        r.controller = f
                    end
                end
            end
        end
    end
    # Then randomly pick followers from the supply
    for region in board.regions
        while region.size < region_size
            pick = random_pick_from_supply(board)
            region.followers[pick] += 1
            region.size += 1
            board.supply[pick] -= 1
        end
    end
end

function resolve_region!(board::Board, region::String)
    index = 0
    for (i, r) in enumerate(board.unresolved_regions)
        if r.name == region
            # Check which faction controls this region
            max_followers = maximum([v for (k,v) in r.followers])
            controlling_factions = [k for (k,v) in r.followers if v == max_followers]
            if length(controlling_factions) == 1
                r.controller = controlling_factions[1]
            else
                r.controller = "France"
                board.invasions += 1
            end
            r.resolved = true
            # Return all followers to the supply
            for (f_name, f_num) in r.followers
                board.supply[f_name] += f_num
            end
            index = i
        end
    end
    if index == 0
        error("The region to be resolved does not exist in the unresolved regions\n",
              "Tried to resolve ", region)
    end
    push!(board.resolved_regions, board.unresolved_regions[index])
    deleteat!(board.unresolved_regions, index)
end

function resolve_board!(board::Board)
    while length(board.unresolved_regions) > 0
        r = board.unresolved_regions[1]
        resolve_region!(board, r.name)
    end
end

function evaluate_current_board(board::Board)
    evaluation = 0
    player = board.players[board.turn]
    for r in board.resolved_regions
        evaluation += get(player.court, r.controller,
                        minimum([v for (k,v) in player.court]))
    end
    evaluation
end

function evaluate_resolved_board(board::Board)
    board_copy = deepcopy(board)
    resolve_board!(board_copy)
    evaluate_current_board(board_copy)
end

function get_follower_options(region::Region)
    options = Vector{String}()
    for (follower_name, num) in region.followers
        if num > 0
            push!(options, follower_name)
        end
    end
    return options
end

function get_follower_options(board::Board)
    options = Dict{String, Vector{String}}()
    for region in board.unresolved_regions
        options[region.name] = get_follower_options(region)
    end
    options_long = []
    i = 1
    for (region, followers) in options
        for follower in followers
            push!(options_long, (region, follower))
            i += 1
        end
    end
    return options_long
end

# TODO: Fix by including player as an argument and using GAME rather than board?
function take_follower(board::Board, player::String, region::String,
                        faction::String)
    board = deepcopy(board)
    for r in board.unresolved_regions
        if r.name == region
            if r.followers[faction] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            r.followers[faction] -= 1
            r.size -= 1
            board.players[board.turn].court[faction] += 1
            board.players[board.turn].court_size += 1
        end
    end
    return board
end

function take_follower!(board::Board, region::String,
                        faction::String)
    for r in board.unresolved_regions
        if r.name == region
            if r.followers[faction] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            r.followers[faction] -= 1
            r.size -= 1
            board.players[board.turn].court[faction] += 1
            board.players[board.turn].court_size += 1
        end
    end
end

function take_follower!(board::Board, player::Player,
    p::Pair{String, String})
    take_follower!(board, player, p.first, p.second)
end

function manoueuvre!(board::Board, (region1, faction1)::Tuple{String, String},
                    (region2, faction2)::Tuple{String, String})
    # First get all valid combinations
    # Get all pairs of regions to swap between
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

    for r in board.unresolved_regions
        if r.name == region1
            if r.followers[faction1] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            r.followers[faction1] -= 1
            r.followers[faction2] += 1
        end
        if r.name == region2
            if r.followers[faction2] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            r.followers[faction2] -= 1
            r.followers[faction1] += 1
        end
    end
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

function apply_action!(board::Board, action::Action)
    return apply_action(board, action)
end

function apply_action(board::Board, action::Action)
    board = deepcopy(board)
    action.action_fun(board, action.argument...)
    return board
end
