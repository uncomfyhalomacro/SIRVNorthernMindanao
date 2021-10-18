module SIRVNorthernMindanao

# Packages
using Agents
using CSV
using DataFrames
using Dates
using Distributions: Poisson, DiscreteNonParametric
using Downloads
using DrWatson: @dict
using FileIO
using GLMakie
using Graphs
using Random


# Includes
include("core.jl")
include("steps.jl")
include("render.jl")

end # module
