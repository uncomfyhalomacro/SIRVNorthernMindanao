using Agents, Random, DataFrames, LightGraphs
using Distributions: Poisson, DiscreteNonParametric
using DrWatson: @dict
using CairoMakie
using LinearAlgebra: diagind

mutable struct Person <: AbstractAgent
    id::Int
    pos::Int
    days_infected::Int
    status::Symbol # 1: S, 2: I, 3:R, 4:V
end

function model_initiation(
    Ns,
    migration_rates,
    β_und,
    β_det,
    infection_period=30,
    reinfection_probability=0.05,
    detection_time=14,
    death_rate=0.02,
    vaccination_rate=0.09,
    Is = [zeros(Int, length(Ns) - 1)..., 1],
    seed=0,
)
    rng = MersenneTwister(seed)
    @assert length(Ns) ==
            length(Is) ==
            length(β_und) ==
            length(β_det) ==
            size(migration_rates, 1) "length of Ns, Is, and β, and number of rows/columns in migration_rates should be the same"
    @assert size(migration_rates, 1) == size(migration_rates, 2)

    C = length(Ns)
    migration_rates_sum = sum(migration_rates; dims=2)
    for c in 1:C
        migration_rates[c, :] ./= migration_rates_sum[c]
    end

    return properties = @dict(
        Ns,
        Is,
        β_und,
        β_det,
        β_det,
        migration_rates,
        infection_period,
        infection_period,
        reinfection_probability,
        detection_time,
        C,
        death_rate,
        vaccination_rate
    )

    space = GraphSpace(complete_digraph(C))
    model = ABM(Person, space; properties, rng)

    for city in 1:C, n in 1:Ns[city]
        ind = add_agent!(city, model, 0, :S)
    end

    for city in 1:C
        inds = ids_in_position(city,model)
        for n in 1:Is[city]
            agent = model[inds[n]]
            agent.status = :I
            agent.days_infected = 1
        end
    end

end


