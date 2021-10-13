using Agents

mutable struct Person <: AbstractAgent 
    id::Int
    pos::Int
    days_infected::Int
    status::Symbol # 1: S, 2: I, 3:R, 4:V
end
