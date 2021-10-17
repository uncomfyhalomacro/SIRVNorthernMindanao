module SIRVNorthernMindanao

# Packages
using Agents
using CSV
using DataFrames
using Dates
using Distributions: Poisson, DiscreteNonParametric
using Downloads
using DrWatson: @dict
using GLMakie
using Random

# Includes
include("core.jl")
include("steps.jl")
include("run.jl")
include("render.jl")
end # module
