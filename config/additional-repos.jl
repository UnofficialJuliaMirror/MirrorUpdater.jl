include("juliacomputing-repos.jl")
include("julialang-repos.jl")
include("miscellaneous-gpu-related-repos.jl")
include("miscellaneous-julia-related-repos.jl")
include("miscellaneous-ml-related-repos.jl")
include("unregistered-packages.jl")

const ADDITIONAL_REPOS = convert(
    Vector{MirrorUpdater.Types.SrcDestPair},
    vcat(
        JULIACOMPUTING_REPOS,
        JULIALANG_REPOS,
        MISCELLANEOUS_GPU_RELATED_REPOS,
        MISCELLANEOUS_JULIA_RELATED_REPOS,
        MISCELLANEOUS_ML_RELATED_REPOS,
        UNREGISTERED_PACKAGES,
        ),
    )
