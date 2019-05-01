include("broken-url-list.jl")
include("git-lfs-repos-url-list.jl")

const DO_NOT_TRY_URL_LIST = convert(
    Vector{String},
    vcat(
        BROKEN_URL_LIST,
        GIT_LFS_REPO_URL_LIST,
        ),
    )
