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

function git_version()::VersionNumber
    git::String = _get_git_binary_path()
    a::String = convert(String,read(`$(git) --version`, String))
    b::String = convert(String, strip(a))
    c::Vector{SubString{String}} = split(b, "git version")
    d::String = convert(String,last(c))
    e::String = convert(String, strip(d))
    f::VersionNumber = VersionNumber(e)
    return f
end

function clean_up_branch_name(x::String)::String
    temp::String = strip(
        strip(
            strip(
                strip(
                    strip(x,),
                    '*',
                    ),
                ),
            '*',
            ),
        )
    my_regex::Regex = r"[a-zA-Z0-9_-]*\/[a-zA-Z0-9_-]*\/([a-zA-Z0-9_-]*)"
    if occursin(my_regex, temp)
        my_match::RegexMatch = match(my_regex, temp)
        just_the_branch::String =
            clean_up_branch_name(first(my_match.captures))
        result = just_the_branch
    else
        result = temp
    end
    return result
end

clean_up_branch_name(x::AbstractString) = clean_up_branch_name(
    convert(String, x)
    )

function get_all_branches_local()
    git::String = _get_git_binary_path()
    a::String = read(`$(git) branch`, String)
    b::String = convert(String, strip(a))
    c::Vector{SubString{String}} = split(b, '\n')
    d::Vector{String} = clean_up_branch_name.(c)
    e::Vector{String} = sort(unique(d))
    return e
end

function get_all_branches_local_and_remote()::Vector{String}
    git::String = _get_git_binary_path()
    a::String = read(`$(git) branch -a`, String)
    b::String = convert(String, strip(a))
    c::Vector{SubString{String}} = split(b, '\n')
    d::Vector{String} = clean_up_branch_name.(c)
    e::Vector{String} = sort(unique(d))
    return e
end

function get_current_branch()::String
    git::String = _get_git_binary_path()
    a::String = read(`$(git) status`, String)
    b::String = convert(String, strip(a))
    c::Vector{SubString{String}} = split(b, '\n')
    d::String = convert(String, strip(first(c)))
    my_regex::Regex = r"On branch ([a-zA-Z0-9_-]*)"
    if occursin(my_regex, d)
        my_match::RegexMatch = match(my_regex, d)
        just_the_branch::String =
            clean_up_branch_name(first(my_match.captures))
        return just_the_branch
    else
        error("could not determine current branch")
    end
end

function checkout_branch!(
    branch_name::AbstractString;
    create::Bool = false,
    error_on_failure::Bool = true,
    )::Nothing

    success::Bool = false

    git::String = _get_git_binary_path()

    branch_name_cleaned::String = clean_up_branch_name(
        branch_name
        )

    try
        run(`$(git) checkout $(branch_name_cleaned)`)
    catch e1
        @warn(string("ignoring exception"), e1,)
    end

    current_branch_1::String = get_current_branch()
    if strip(current_branch_1) == strip(branch_name_cleaned)
        success = true
    else
        success = false
    end

    if !success
        if create
            try
                run(`$(git) checkout --orphan $(branch_name_cleaned)`)
            catch e2
                @warn(string("ignoring exception"), e2,)
            end
        end
    end

    current_branch_2::String = get_current_branch()
    if strip(current_branch_2) == strip(branch_name_cleaned)
        success = true
    else
        success = false
    end

    if !success
        if error_on_failure
            error("could not checkout the specified branch")
        else
            @warn("could not checkout the specified branch")
        end
    end

    return nothing
end

function branch_exists(branch_name::AbstractString)::Bool
    git::String = _get_git_binary_path()
    original_branch::String = get_current_branch()
    branch_name_cleaned::String = clean_up_branch_name(
        branch_name
        )
    try
        run(`$(git) checkout $(branch_name_cleaned)`)
    catch e
        @warn(string("ignoring exception"), e,)
    end
    current_branch::String = get_current_branch()
    if strip(current_branch)==strip(branch_name_cleaned)
        result = true
    else
        result = false
    end
    run(`$(git) checkout $(original_branch)`)
    return result
end

function git_add_all!()::Nothing
    git::String = _get_git_binary_path()
    try
        run(`$(git) add -A`)
    catch e
    @warn(string("ignoring exception"), e,)
    end
    return nothing
end

function git_commit!(
        ;
        message::AbstractString,
        committer_name::AbstractString,
        committer_email::AbstractString,
        allow_empty::Bool = false,
        )::Nothing
    git::String = _get_git_binary_path()
    message_stripped::String = convert(
        String,
        strip(message),
        )
    committer_name_stripped::String = convert(
        String,
        strip(committer_name),
        )
    committer_email_stripped::String = convert(
        String,
        strip(committer_email),
        )
    allow_empty_flag::String = ""
    if allow_empty
        allow_empty_flag = "--allow-empty"
    else
        allow_empty_flag = ""
    end
    run(`$(git) config user.name "$(committer_name_stripped)"`)
    run(`$(git) config user.email "$(committer_email_stripped)"`)
    run(`$(git) config commit.gpgsign false`)
    try
        run(`$(git) commit $(allow_empty_flag) -m "$(message_stripped)"`)
    catch e
        @warn(string("ignoring exception"), e,)
    end
    return nothing
end

function git_push_upstream_all!()::Nothing
    git::String = _get_git_binary_path()
    try
        run(`$(git) push -u --all`)
    catch e
    @warn(string("ignoring exception"), e,)
    end
    return nothing
end

function delete_everything_except_dot_git!(
        root_path::AbstractString,
        )::Nothing
    previous_directory::String = pwd()

    list_of_paths_to_remove::Vector{String} = Vector{String}()

    root_path_stripped::String = convert(String, strip(root_path))

    for file_or_directory in readdir(root_path_stripped)
        if strip(lowercase(file_or_directory)) != ".git"
            push!(
                list_of_paths_to_remove,
                joinpath(root_path_stripped, file_or_directory,),
                )
        end
    end

    for path_to_remove in list_of_paths_to_remove
        rm(
            path_to_remove;
            force = true,
            recursive = true,
            )
    end

    cd(previous_directory)
    return nothing
end

function delete_only_dot_git!(root_path::AbstractString)::Nothing
    previous_directory::String = pwd()

    list_of_paths_to_remove::Vector{String} = Vector{String}()

    root_path_stripped::String = convert(String, strip(root_path))

    for (rootdir, dirs, files) in walkdir(root_path_stripped)
        for dir in dirs
            if strip(lowercase(dir)) == ".git"
                push!(
                    list_of_paths_to_remove,
                    joinpath(rootdir, dir),
                    )
            end
        end
        for file in files
            if strip(lowercase(file)) == ".git"
                push!(
                    list_of_paths_to_remove,
                    joinpath(rootdir, file),
                    )
            end
        end
    end

    for path_to_remove in list_of_paths_to_remove
        rm(
            path_to_remove;
            force = true,
            recursive = true,
            )
    end

    cd(previous_directory)
    return nothing
end

function _include_branch(
        ;
        include::AbstractVector,
        branch::String,
        )::Bool
    branch_clean::String = clean_up_branch_name(branch)
    matches_any_inclusion_criteria::Vector{Bool} = Bool[
        occursin(x, branch_clean) for x in include
        ]
    result::Bool = any(matches_any_inclusion_criteria)
    return result
end

function _exclude_branch(
        ;
        exclude::AbstractVector,
        branch::String,
        )::Bool
    branch_clean::String = clean_up_branch_name(branch)
    matches_any_exclusion_criteria::Vector{Bool} = Bool[
        occursin(x, branch_clean) for x in exclude
        ]
    result::Bool = any(matches_any_exclusion_criteria)
    return result
end

function make_list_of_branches_to_snapshot(
        ;
        default_branch::String,
        include::AbstractVector,
        exclude::AbstractVector,
        )::Vector{String}

    all_branches::Vector{String} = get_all_branches_local_and_remote()

    first_pass::Vector{String} = Vector{String}()

    default_br_cl_lc_s::String = strip(
        lowercase(
            clean_up_branch_name(
                default_branch
                )
            )
        )

    for b_1 in all_branches
        if default_br_cl_lc_s == strip(lowercase(clean_up_branch_name(b_1)))
            push!(first_pass, b_1)
        end
    end

    for b_2 in all_branches
        if _include_branch(;branch=b_2,include=include)
            push!(first_pass, b_2)
        end
    end

    branches_to_snapshot::Vector{String} = Vector{String}()

    for b_3 in first_pass
        if !_exclude_branch(;branch=b_3,exclude=exclude)
            push!(branches_to_snapshot, b_3)
        end
    end

    branches_to_snapshot_cleaned::Vector{String} = clean_up_branch_name.(
        branches_to_snapshot
        )

    result::Vector{String} = sort(unique(branches_to_snapshot_cleaned))

    return result
end

##### End of file
