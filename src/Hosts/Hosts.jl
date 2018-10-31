##### Beginning of file

module Hosts # Begin submodule MirrorUpdater.Hosts

__precompile__(true)

import ..Types
import ..Utils

include(joinpath("BitbucketHost", "BitbucketHost.jl"))
include(joinpath("GitHubHost", "GitHubHost.jl"))
include(joinpath("GitLabHost", "GitLabHost.jl"))

end # End submodule MirrorUpdater.Hosts

##### End of file
