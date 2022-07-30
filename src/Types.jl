# Module for The King is Dead bot
# This houses all of the types

struct Faction
    name::String
end

mutable struct Player
    name::String
    court::Dict{String, Int64}
    court_size::Int8
end

struct Action
    player::Player
    action_name
    action_fun
    argument::Tuple
end

mutable struct Region
    name::String
    followers::Dict{String, Int64}
    size::Int8
    resolved::Bool
    controller::Union{String, Nothing}
    adjacent::Array{String}
end

mutable struct Board
    regions::Array{Region}
    unresolved_regions::Array{Region}
    resolved_regions::Array{Region}
    supply::Dict{String, Int64}
    invasions::Int8
    players::Array{Player}
end

struct Card
    name::String
    type::String
    adjacent::Union{String, Bool}
    place::Union{Dict{String, Int64}, Nothing}
    swap::Union{Dict{String, Int64}, Nothing}
end


mutable struct Game
    board::Board
    actions::Array{Action}
    turn::Int64
    initial_board::Board
end

function Game(board::Board, actions::Vector{Action})
    Game(board, actions, 1, deepcopy(board))
end

function Board(regions, players)
    supply = Dict{String, Int64}()
    for (f_name, _) in faction_names
        supply[f_name] = 18 # Start with 18 followers in each faction
    end
    Board(regions, shuffle(regions), Array{Region}(undef, 0), supply, 0, players)
end

function Region(name, followers::Dict{String, Int64}, size::Int, adjacent::Array{String})
    Region(name, followers, size, false, nothing, adjacent)
end

function Player(name)
    Player(name, Dict(k=>0 for k in keys(faction_names)), 0) # Each player starts with 0 followers of each faction
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

function Base.getindex(regions::Vector{Region}, region_name::String)
    for r in regions
        if r.name == region_name
            return r
        end
    end
end
