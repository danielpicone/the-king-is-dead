# Module for The King is Dead bot
# This houses all of the types

struct Faction
    name::String
end

mutable struct Region
    name::String
    followers::Dict{String, Int64}
    size::Int8
    resolved::Bool
    controller::Union{String, Nothing}
    adjacent::Array{String}
end

mutable struct Supply
    followers::Dict{String, Int64}
end

mutable struct Board
    regions::Array{Region}
    unresolved_regions::Array{Region}
    resolved_regions::Array{Region}
    supply::Supply
    invasions::Int8
end

mutable struct Player
    name::String
    court::Dict{String, Int64}
    court_size::Int8
end

function Board(regions, supply)
    Board(regions, shuffle(regions), Array{Region}(undef, 0), supply, 0)
end

function Region(name, followers::Dict{String, Int64}, size::Int, adjacent::Array{String})
    Region(name, followers, size, false, nothing, adjacent)
end

function Supply(factions::Array)
    followers = Dict{String, Int64}()
    for f in factions
        followers[f] = 18
    end
    Supply(followers)
end

function Supply(factions::Dict)
    Supply(collect(keys(factions)))
end

function Player(name)
    Player(name, Dict(k=>0 for k in keys(faction_names)), 0)
end
