##### Beginning of file

import ..package_directory

function _get_git_binary_path()::String
    deps_jl_file_path = package_directory("deps", "deps.jl")
    if !isfile(deps_jl_file_path)
        error(
            string(
                "MirrorUpdater.jl is not properly installed. ",
                "Please run\nPkg.build(\"MirrorUpdater\")",
                )
            )
    end
    include(deps_jl_file_path)
    git::String = strip(string(git_cmd))
    run(`$(git) --version`)
    @debug(
        "git command: ",
        git,
        )
    return git
end

##### End of file
