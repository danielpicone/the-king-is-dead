# Module for The King is Dead bot
# This houses all of the types

import Base: show

Base.show(io::IO, b::Board) = begin
    regions = [merge(Dict("name" => r.name), r.followers) for
                        r in b.regions]
    df = vcat(DataFrame.(regions)...)
    local followers = Symbol.(sort(collect(keys(b.regions[1].followers))))
    select!(df, [:name, followers...])
    println(df)
    print("Resolved regions: ", )
    for (i, r) in enumerate(b.resolved_regions)
        if i == length(b.resolved_regions)
            print(r.name)
        else
            print(r.name, ", ")
        end
    end
    print("\nRegions to be resolved in order: ", )
    for (i, r) in enumerate(b.unresolved_regions)
        if i == length(b.unresolved_regions)
            println(r.name)
        else
            print(r.name, ", ")
        end
    end
    println("Invasions: ", b.invasions)
end
# Base.show(io::IO, b::Board) = begin
#     total_followers = Dict{String, Int64}()
#     for (f_name, _) in b.regions[1].followers
#         total_followers[f_name] = 0
#     end
#     for r in b.regions
#         print(r.name, " has: ")
#         for (i, (f_name, f_num)) in enumerate(r.followers)
#             total_followers[f_name] += f_num
#             if (i == length(r.followers))
#                 println(f_num, " ", f_name, " followers.")
#             else
#                 print(f_num, " ", f_name, ", ")
#             end
#         end
#     end
#     print("\nFor a total of ")
#     for (i, (f_name, f_num)) in enumerate(total_followers)
#         if (i == length(total_followers))
#             println(f_num, " ", f_name, " followers.")
#         else
#             print(f_num, " ", f_name, ", ")
#         end
#     end
#
# end

Base.show(io::IO, p::Player) = begin
    print(p.name, " has ")
    for (i, (f_name, f_num)) in enumerate(p.court)
        if (i == length(p.court))
            print(f_num, " ", f_name, " followers.")
        else
            print(f_num, " ", f_name, ", ")
        end
    end
end

Base.show(io::IO, region::Region) = print(region.name)

Base.print(io::IO, region::Region) = begin
    println(region.name)
    println(region.followers)
    print("Neighbouring regions: ")
    for (i, str) in enumerate(region.adjacent)
        if (i == length(region.adjacent))
            print(str)
        else
            print(str, ", ")
        end
    end
    println()
end

Base.show(io::IO, ps::Array{Player}) = begin
    [Base.show(p) for p in ps]
end

Base.show(io::IO, tup::Tuple{Tuple{Region, String}, Tuple{Region, String}}) = begin
    print("(", tup[1][1].name, ", ", tup[1][2],"), (", tup[2][1].name, ", ", tup[2][2], ")")
end
