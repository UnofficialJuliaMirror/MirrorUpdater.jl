##### Beginning of file

# Parts of this file are based on:
# 1. https://github.com/JuliaPackaging/Git.jl/blob/master/deps/build.jl

import Pkg

function _default_git_cmd()::String
    result::String = lowercase(strip("git"))
    return result
end

function _found_default_git()::Bool
    default_git_cmd::String = _default_git_cmd()
    found_default_git::Bool = try
        success(`$(default_git_cmd) --version`)
    catch
        false
    end
    return found_default_git
end

function _install_git()::String
    result::String = _install_git_conda()
    return result
end

function _install_git_conda()::String
    @info("Attempting to install Conda.jl...")
    conda_package_spec = Pkg.PackageSpec(
        name = "Conda",
        version = "1.1.1",
        )
    Pkg.add(conda_package_spec)
    import Conda
    @info("Successfully installed Conda.jl...")
    @info("Attempting to install Git using Conda.jl...")
    environment::Symbol = :MirrorUpdater
    Conda.add("git", environment)
    @info("Successfully installed Git using Conda.jl.")
    git_cmd::String = strip(
        joinpath(
            Conda.bin_dir(environment),
            "git",
            )
        )
    run(`$(git_cmd) --version`)
    return git_cmd
end

function _build_git()::String
    install_git::Bool = lowercase(strip(get(ENV, "INSTALL_GIT", "false"))) ==
        lowercase(strip("true"))
    found_default_git::Bool = _found_default_git()
    if install_git
        @info("INSTALL_GIT is true, so I will now install git.")
        git_cmd = _install_git()
    elseif found_default_git
        @info("I found git on your system, so I will use that git.")
        git_cmd = _default_git_cmd()
    else
        @info("I did not find git on your system, so I will now install git.")
        git_cmd = _install_git()
    end
    return git_cmd
end

function _build_mirrorupdater()::Nothing
    git_cmd = _build_git()
    build_jl_file_path = strip(
        abspath(
            strip(
                @__FILE
                )
            )
        )
    @debug(
        "deps/build.jl: ",
        build_jl_file_path,
        )
    deps_directory = strip(
        abspath(
            strip(
                dirname(
                    strip(
                        build_jl_file_path
                        )
                    )
                )
            )
        )
    @debug(
        "deps:",
        deps_directory,
        )
    deps_jl_file_path = strip(
        abspath(
            joinpath(
                strip(deps_directory),
                strip("deps.jl"),
                )
            )
        )
    @debug(
        "deps/",
        ,
        )
    open(deps_jl_file_path, "w") do f
        line_1::String = "git_cmd = \"$(strip(string(git_cmd)))\""
        @info("Writing line 1 to deps.jl: ", line_1,)
        println(f, line_1)
    end
    return nothing
end

_build_mirrorupdater()

##### End of file
