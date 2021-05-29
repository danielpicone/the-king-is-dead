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

mutable struct Player
    name::String
    court::Dict{String, Int64}
    court_size::Int8
end

mutable struct Board
    regions::Array{Region}
    unresolved_regions::Array{Region}
    resolved_regions::Array{Region}
    supply::Dict{String, Int64}
    invasions::Int8
    players::Array{Player}
    turn::Int8
end

struct Card
    name::String
    type::String
    adjacent::Union{String, Bool}
    place::Union{Dict{String, Int64}, Nothing}
    swap::Union{Dict{String, Int64}, Nothing}
end

function Board(regions, players)
    supply = Dict{String, Int64}()
    for (f_name, _) in faction_names
        supply[f_name] = 18
    end
    Board(regions, shuffle(regions), Array{Region}(undef, 0), supply, 0, players, 1)
end

function Region(name, followers::Dict{String, Int64}, size::Int, adjacent::Array{String})
    Region(name, followers, size, false, nothing, adjacent)
end

function Player(name)
    Player(name, Dict(k=>0 for k in keys(faction_names)), 0)
end

function Card(name, card)
    for (k,v) in card
        if v == "nothing"
            card[k] = nothing
        elseif typeof(v) == Dict{String, Any}
            try
                card[k] = convert(Dict{String, Int}, v)
            catch
            end
        end
    end
    Card(name, card["type"], card["adjacent"], card["place"], card["swap"])
end
