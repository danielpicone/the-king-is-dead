# Module for The King is Dead bot
# This houses all of the functions

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
    # First put followers in home bases
    for region in board.regions
        for (f, starting_region) in faction_names
            if region.name == starting_region
                region.followers[f] += 2
                region.size = 2
                board.supply[f] -= 2 # Reduce the supply
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

function evaluate_current_board(board::Board, player::Player)
    evaluation = 0
    for r in board.resolved_regions
        evaluation += get(player.court, r.controller,
                        minimum([v for (k,v) in player.court]))
    end
    evaluation
end

function take_follower!(board::Board, player::Player, region::String,
                        faction::String)
    for r in board.unresolved_regions
        if r.name == region
            if r.followers[faction] == 0
                error("Trying to take a follower from a region where that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from ", region)
            end
            r.followers[faction] -= 1
            r.size -= 1
            player.court[faction] += 1
            player.court_size += 1
        end
    end
end

function take_follower!(board::Board, player::Player,
    p::Pair{String, String})
    take_follower!(board, player, p.first, p.second)
end

function place_follower!(board::Board, region::String, faction::String)
    for r in board.unresolved_regions
        if r.name == region
            if board.supply[faction] == 0
                error("Trying to take a follower from the supply when that faction is not present\n",
                "Tried to take a(n) ", faction, " follower from the supply")
            end
            r.followers[faction] += 1
            r.size += 1
            board.supply[faction] -= 1
        end
    end
end

function place_follower!(board::Board, d::Pair{String, String})
    place_follower!(board, d.second, d.first)
end
