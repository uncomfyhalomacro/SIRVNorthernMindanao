using FileIO

# Defining the agent
@agent Individual GraphSpace begin
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
    detection_time=14σ = 0.02,
    γS=[zeros(Int, length(N) - 1)..., 1],
    seed=0,
)
    rng = MersenneTwister(seed)
    @assert length(Ns) ==
        length(γS) ==
        length(β_und) ==
        length(β_det) ==
        size(migration_rates, 1)
    C = length(Ns)
    δ_sum = sum(δ; dims=2)
    for c in 1:C
        δ[c, :] ./= δ_sum[c]
    end

    properties = @dict() 
end

function params()
end
