##### Beginning of file

module GitHubMirrorUpdater # Begin submodule MirrorUpdater.GitHubMirrorUpdater

__precompile__(true)

import ..Utils

import ..AbstractInterval

import ..OneSidedInterval
import ..Package
import ..Registry
import ..SrcDestPair
import ..TwoSidedInterval

import .._construct_interval
import .._is_interval

import .._name_with_git
import .._name_without_git
import .._name_with_jl
import .._name_without_jl

include("main-method.jl")
include("methods.jl")
include("parse-arguments.jl")

end # End submodule MirrorUpdater.GitHubMirrorUpdater

##### End of file
