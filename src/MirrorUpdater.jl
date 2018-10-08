##### Beginning of file

module MirrorUpdater # Begin module MirrorUpdater

__precompile__(true)

include(joinpath("Types", "Types.jl"))

include(joinpath("Common", "Common.jl"))
include(joinpath("Hosts", "Hosts.jl"))
include(joinpath("Run", "Run.jl"))
include(joinpath("Utils", "Utils.jl"))
include(joinpath("GitHubMirrorUpdater", "GitHubMirrorUpdater.jl"))

end # End module MirrorUpdater

##### Beginning of file
