# Module for The King is Dead bot
# This houses all of the functions

function random_pick_from_supply(supply::Supply)
    supply_array = Array{String}(undef, 0)
    for (f_name, f_num) in supply.followers
        append!(supply_array, repeat([f_name], f_num))
    end
    pick = supply_array[rand(1:length(supply_array))]
    return pick
end

function initialise_player_courts!(players::Array{Player}, supply::Supply)
    for player in players
        while player.court_size < court_size
            pick = random_pick_from_supply(supply)
            player.court[pick] += 1
            player.court_size += 1
            supply.followers[pick] -= 1
        end
    end
end

function initialise_board!(board::Board, supply::Supply)
    for region in regions
        while region.size < region_size
            pick = random_pick_from_supply(supply)
            region.followers[pick] += 1
            region.size += 1
            supply.followers[pick] -= 1
        end
    end
end

function resolve_region!(board::Board, region::String)
    index = 0
    for (i, r) in enumerate(board.unresolved_regions)
        if r.name == region
            max_followers = maximum([v for (k,v) in r.followers])
            controlling_factions = [k for (k,v) in r.followers if v == max_followers]
            if length(controlling_factions) == 1
                r.controller = controlling_factions[1]
            else
                r.controller = "France"
                board.invasions += 1
            end
            r.resolved = true
            index = i
        end
    end
    if index == 0
        println("THERE IS AN ERROR")
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
