##### Beginning of file

module MirrorUpdater # Begin module MirrorUpdater

__precompile__(true)

include("abstract-types.jl")
include("concrete-types.jl")

include(joinpath("Utils", "Utils.jl"))

include(joinpath("GitHubMirrorUpdater", "GitHubMirrorUpdater.jl"))

end # End module MirrorUpdater

##### Beginning of file
