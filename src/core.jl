using FileIO
using LightGraphs

# Defining the agent
mutable struct Individual <: AbstractAgent
    id::Int
    pos::Int
    days_infected::Int
    days_recovered::Int
    status::Symbol  # :S -> susceptible, :I -> infected, :R -> recovered, :V -> vaccinated
end

# Defining the model
function model_initiation(;
    Ns,
    δ,  # migration rates
    β_und,
    β_det,
    infection_period=30,  # no. until person dies or recovers
    recovery_period=90,  # no. days to full recovery
    detection_time=14,
    reinfection_probability = 0.05,
    death_rate = 0.02,
    vaccination_interval=14,
    γS=[zeros(Int, length(Ns) - 1)..., 1],
    seed=0,
)
    rng = MersenneTwister(seed)
    @assert length(Ns) ==
        length(γS) ==
        length(β_und) ==
        length(β_det) ==
        size(δ, 1)
    C = length(Ns)
    δ_sum = sum(δ; dims=2)
    for c in 1:C
        δ[c, :] ./= δ_sum[c]
    end

    properties = @dict(
        Ns,
        γS,
        β_und,
        β_det,
        δ,
        infection_period,
        recovery_period,
        reinfection_probability,
        detection_time,
        C,
        vaccination_interval,
        death_rate,
    )
    space = GraphSpace(complete_digraph(C))
    model = ABM(Individual, space; properties, rng)

    # Add initial individuals
    for city in 1:C, n in 1:Ns[city]
        ind = add_agent!(city, model, 0, 0, :S)  # susceptible
    end

    for city in 1:C
        inds = ids_in_position(city, model)
        for n in 1:γS[city]
            agent = model[inds[n]]
            agent.status = :I  # infected
            agent.days_infected = 1
        end
    end

    return model
end

using LinearAlgebra: diagind

function generate_params(;
    C,
    max_travel_rate,
    infection_period=30,
    recovery_period=90,
    reinfection_probability=0.05,
    detection_time=14,
    death_rate=0.02,
    γS=[zeros(Int, C - 1)..., 1],
    seed=19,
)
    Random.seed!(seed)
    Ns = rand(50:5000, C)  # Randomize this for now
    β_und = rand(0.3:0.02:0.6, C)
    β_det = β_und ./ 10

    Random.seed!(seed)
    δ = zeros(C, C)
    for c in 1:C
        for c2 in 1:C
            δ[c, c2] = (Ns[c] + Ns[c2]) / Ns[c]
        end
    end
    maxM = maximum(δ)
    δ = (δ .* max_travel_rate) ./ maxM
    δ[diagind(δ)] .= 1.0

    params = @dict(
        Ns,
        β_und,
        β_det,
        δ,
        infection_period,
        recovery_period,
        reinfection_probability,
        detection_time,
        death_rate,
        γS
    )

    return params
end

params = generate_params(; C=8, max_travel_rate=0.01)
model = model_initiation(; params...)
