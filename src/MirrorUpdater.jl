##### Beginning of file

module MirrorUpdater # Begin module MirrorUpdater

__precompile__(true)

include(joinpath("package_directory.jl"))
include(joinpath("version.jl"))
include(joinpath("welcome.jl"))

include(joinpath("Types", "Types.jl"))

include(joinpath("Utils", "Utils.jl"))

include(joinpath("Common", "Common.jl"))

include(joinpath("Run", "Run.jl"))

include(joinpath("CommandLine", "CommandLine.jl"))

include(joinpath("Hosts", "Hosts.jl"))

include(joinpath("init.jl"))

end # End module MirrorUpdater

##### Beginning of file
