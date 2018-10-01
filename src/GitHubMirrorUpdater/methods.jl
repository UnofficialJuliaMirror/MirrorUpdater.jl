##### Beginning of file

import ArgParse
import Conda
import GitHub
import HTTP
import Pkg

function _get_repo_fullname(
        x::SrcDestPair,
        github_organization::String,
        )::String
    destination_repo_name::String = strip(x.destination_repo_name)
    result::String = string(
        github_organization,
        "/",
        destination_repo_name,
        )
    return result
end

function _get_destination_url(
        x::SrcDestPair,
        github_organization::String,
        ):String
    destination_repo_name::String = strip(x.destination_repo_name)
    result::String = string(
        "https://github.com/",
        github_organization,
        "/",
        destination_repo_name,
        )
    return result
end

function _get_destination_url(
        x::SrcDestPair,
        github_organization::String,
        github_user::String,
        github_token::String,
        ):String
    destination_repo_name::String = strip(x.destination_repo_name)
    result::String = string(
        "https://",
        github_user,
        ":",
        github_token,
        "@github.com/",
        github_organization,
        "/",
        destination_repo_name,
        )
    return result
end

function _create_dest_repo_if_it_doesnt_exist(
        x::SrcDestPair,
        github_organization::String,
        github_user::String,
        github_token::String;
        auth::GitHub.Authorization,
        )::Nothing
    repo_fullname = _get_repo_fullname(x, github_organization,)
    dest_url_withoutauth = _get_destination_url(
        x,
        github_organization,
        )
    if _url_exists(dest_url_withoutauth)
        # repo already exists, so do nothing
    else
        if _github_repo_exists(repo_fullname; auth=auth)
            # repo already exists, so do nothing
        else
            @info("Creating new repo: $(dest_url_withoutauth)")
            destination_repo_name::String = strip(x.destination_repo_name)
            owner = GitHub.owner(
                github_organization,
                true;
                auth = auth,
                )
            params = Dict{String, Any}(
                # "private" => "false",
                "has_issues" => "false",
                # "has_projects" => "false",
                "has_wiki" => "false",
                )
            repo = GitHub.create_repo(
                owner,
                destination_repo_name,
                params;
                auth = auth,
                )
        end
    end
    return nothing
end

function _url_exists(url::AbstractString)::Bool
    temp_url::String = strip(convert(String, url))
    result::Bool = try
        r = HTTP.request("GET", url)
        r.status == 200
    catch
        false
    end
    return result
end

function _github_repo_exists(
        full_repo_name;
        auth::GitHub.Authorization,
        )::Bool
    result::Bool = try
        repo = GitHub.repo(full_repo_name; auth = auth,)
        true
    catch
        false
    end
    return result
end

function _toml_file_to_package(packagetoml_file_filename::String)::Package
    toml_file_text::String = read(packagetoml_file_filename, String)
    toml_file_parsed::Dict{String,Any}=Pkg.TOML.parse(toml_file_text)
    pkg_name::String = toml_file_parsed["name"]
    pkg_uuid::String = toml_file_parsed["uuid"]
    pkg_source_url::String = toml_file_parsed["repo"]
    pkg::Package = Package(
        ;
        name=pkg_name,
        uuid=pkg_uuid,
        source_url=pkg_source_url,
        )
    return pkg
end

function _get_uuid_from_toml_file(toml_file_filename::String)::String
    toml_file_text::String = read(toml_file_filename, String)
    toml_file_parsed::Dict{String,Any}=Pkg.TOML.parse(toml_file_text)
    uuid::String = toml_file_parsed["uuid"]
    return uuid
end

function _make_list(
        registry_list::Vector{Registry},
        additional_repos::Vector{SrcDestPair};
        do_not_try_url_list::Vector{String},
        try_but_allow_failures_url_list::Vector{String},
        )::Vector{SrcDestPair}
    full_list::Vector{SrcDestPair} = SrcDestPair[]
    for x in additional_repos
        push!(full_list, x)
    end
    git = _get_git_binary_path()
    for registry in registry_list
        registry_name = registry.name
        registry_uuid = registry.uuid
        registry_source_url = registry.url
        registry_destination_repo_name = _generate_destination_repo_name(
            registry
            )
        registry_src_dest_pair = SrcDestPair(
            ;
            source_url = registry_source_url,
            destination_repo_name = registry_destination_repo_name,
            )
        push!(full_list, registry_src_dest_pair)
        if registry_source_url in do_not_try_url_list ||
                _name_with_git(registry_source_url) in do_not_try_url_list ||
                _name_without_git(registry_source_url) in do_not_try_url_list
            blah
            @warn(
                string(
                    "registry_source_url is in the do-not-try list, ",
                    "so skipping.",
                    ),
                registry_source_url,
                )
        else
            previous_dir::String = pwd()
            temp_dir_registry_git_clone_regular::String = mktempdir()
            cd(temp_dir_registry_git_clone_regular)
            cmd_git_clone_registry_regular = `$(git) clone $(registry.url)`
            @info(
                "Attempting to run command",
                cmd_git_clone_registry_regular,
                pwd(),
                )
            clone_registry_regular_was_success =
                Utils.command_ran_successfully(
                    cmd_git_clone_registry_regular;
                    )
            if clone_registry_regular_was_success
                @info("Command ran successfully",)
                registry_toml_filename = joinpath(
                    temp_dir_registry_git_clone_regular,
                    registry_name,
                    "Registry.toml"
                    )
                registry_toml_file_uuid = _get_uuid_from_toml_file(
                    registry_toml_filename
                    )
                if lowercase(strip(registry_uuid)) !=
                        lowercase(strip(registry_toml_file_uuid))
                    error(
                        string(
                            "The UUID ($(registry_toml_file_uuid)) ",
                            "I found in the Registry.toml file does not ",
                            "match the UUID ($(registry_uuid)) ",
                            "that you provided.",
                            )
                        )
                end
                list_of_packagetoml_filenames::Vector{String} = String[]
                for (root, dirs, files) in
                        walkdir(temp_dir_registry_git_clone_regular)
                    for file in files
                        if lowercase(strip(file)) == "package.toml"
                            packagetoml_fn = joinpath(root, file)
                            push!(list_of_packagetoml_filenames, packagetoml_fn)
                        end
                    end
                end
                for packagetoml_file_filename in list_of_packagetoml_filenames
                    pkg = _toml_file_to_package(packagetoml_file_filename)
                    pkg_source_url = pkg.source_url
                    pkg_dest_repo_name = _generate_destination_repo_name(pkg)
                    pkg_src_dest_pair = SrcDestPair(
                        ;
                        source_url=pkg_source_url,
                        destination_repo_name=pkg_dest_repo_name,
                        )
                    push!(full_list, pkg_src_dest_pair)
                end
            else
                @warn(
                    "Command did not run successfully",
                    cmd_git_clone_registry_regular,
                    pwd(),
                    )
                if registry_source_url in try_but_allow_failures_url_list ||
                        _name_with_git(registry_source_url) in
                            try_but_allow_failures_url_list ||
                        _name_without_git(registry_source_url) in
                            try_but_allow_failures_url_list
                    @warn(
                        string(
                            "URL is in the try-but-allow-failures list, ",
                            "so ignoring error ",
                            "that occured when running command",
                            ),
                        cmd_git_clone_registry_regular,
                        pwd(),
                        )
                else
                    error(
                        string(
                            "Encountered error when running command: ",
                            cmd_git_clone_registry_regular,
                            pwd(),
                            )
                        )
                end
            end
            cd(previous_dir)
            rm(
                temp_dir_registry_git_clone_regular;
                force = true,
                recursive = true,
                )
        end
    end
    unique_list_sorted::Vector{SrcDestPair} = sort(unique(full_list))
    return unique_list_sorted
end

function _generate_destination_repo_name(x::Registry)::String
    result::String = string(
        strip(x.owner),
        "-",
        strip(x.name),
        "-",
        strip(x.uuid),
        )
    return result
end

function _generate_destination_repo_name(x::Package)::String
    result::String = string(
        strip(x.name),
        "-",
        strip(x.uuid),
        )
    return result
end

function _src_dest_pair_to_string(x::SrcDestPair)::String
    result::String = string(
        strip(x.source_url),
        " ",
        strip(x.destination_repo_name),
        )
    return result
end

function _src_dest_pair_list_to_string(
        v::Vector{SrcDestPair}
        )::String
    v_sorted_unique::Vector{SrcDestPair} = sort(unique(v))
    lines::Vector{String} = String[
        _src_dest_pair_to_string(x) for x in v_sorted_unique
        ]
    result::String = string(
        join(lines, "\n",),
        "\n",
        )
    return result
end

function _string_to_src_dest_pair_list(
        x::String
        )::Vector{SrcDestPair}
    all_src_dest_pairs = SrcDestPair[]
    lines::Vector{String} = convert(
        Vector{String},
        split(x, "\n",),
        )
    for line in lines
        columns::Vector{String} = convert(
            Vector{String},
            split(strip(line)),
            )
        if length(columns) == 2
            source_url::String = strip(columns[1])
            destination_repo_name::String = strip(columns[2])
            src_dest_pair::SrcDestPair = SrcDestPair(
                ;
                source_url = source_url,
                destination_repo_name = destination_repo_name,
                )
            push!(all_src_dest_pairs, src_dest_pair,)
        end
    end
    src_dest_pairs_sorted_unique::Vector{SrcDestPair} = sort(
        unique(
            all_src_dest_pairs
            )
        )
    return src_dest_pairs_sorted_unique
end

function _remove_problematic_refs_before_github(
        ;
        packed_refs_filename::String,
        )::Nothing
    original_packed_refs_content::String = read(
        packed_refs_filename,
        String,
        )
    original_lines::Vector{String} = convert(
        Vector{String},
        split(strip(original_packed_refs_content), "\n")
        )
    function _line_is_ok_to_keep(x::String)::Bool
        result::Bool = (!(occursin(" refs/pull/", x)))
        return result
    end
    function _determine_new_gh_pages_branch_name(
            content::String,
            suggested_name::String,
            )::String
        if occursin(suggested_name, content)
            result = _determine_new_gh_pages_branch_name(
                content,
                string(suggested_name, "1"),
                )
        else
            result = suggested_name
        end
        return result
    end
    new_name_for_gh_pages_branch = _determine_new_gh_pages_branch_name(
        original_packed_refs_content,
        "gh-pages1",
        )
    function _transform_line(x::String)::String
        result_1::String = replace(
            x,
            "gh-pages" => new_name_for_gh_pages_branch,
            )
        return result_1
    end
    new_lines::Vector{String} = Vector{String}()
    for orig_line in original_lines
        if _line_is_ok_to_keep(orig_line)
            transformed_line = _transform_line(orig_line)
            push!(new_lines, transformed_line)
        end
    end
    new_packed_refs_content::String = string(
        join(new_lines, "\n"),
        "\n",
        )
    rm(
        packed_refs_filename;
        force = true,
        recursive = true,
        )
    write(packed_refs_filename, new_packed_refs_content)
    return nothing
end

function _push_mirrors(
        src_dest_pairs::Vector{SrcDestPair},
        github_organization::String,
        github_user::String,
        github_token::String;
        recursion_level::Integer = 0,
        max_recursion_depth::Integer = 5,
        is_dry_run::Bool = false,
        auth::GitHub.Authorization,
        do_not_push_to_these_destinations::Vector{String},
        do_not_try_url_list::Vector{String},
        try_but_allow_failures_url_list::Vector{String},
        )::Nothing
    @debug(string("Recursion level: $(recursion_level)"))
    src_dest_pairs_sorted_unique::Vector{SrcDestPair} = sort(
        unique(
            src_dest_pairs
            )
        )
    git = _get_git_binary_path()
    grin = _get_grin_binary_path()
    for pair in src_dest_pairs_sorted_unique
        src_url = pair.source_url
        destination_repo_name = pair.destination_repo_name
        destination_repo_fullname = _get_repo_fullname(
            pair,
            github_organization,
            )
        dest_url_withoutauth::String = _get_destination_url(
            pair,
            github_organization,
            )
        dest_url_withauth::String = _get_destination_url(
            pair,
            github_organization,
            github_user,
            github_token,
            )
        dest_url_withredactedauth::String = _get_destination_url(
            pair,
            github_organization,
            github_user,
            "*****",
            )
        if src_url in do_not_try_url_list ||
                _name_with_git(src_url) in do_not_try_url_list ||
                _name_without_git(src_url) in do_not_try_url_list
            @warn(
                string("Src url is in the do not try list, so skipping."),
                src_url,
                )
        else
            previous_dir::String = pwd()
            temp_dir_repo_git_clone_regular::String = mktempdir()
            temp_dir_repo_git_clone_mirror::String = mktempdir()
            if recursion_level <= max_recursion_depth
                @info(
                    string(
                        "Now I will look for additional repos to mirror ",
                        "(e.g. BinaryBuilder repos that are referenced ",
                        "in this repo).",
                        )
                    )
                cd(temp_dir_repo_git_clone_regular)
                cmd_git_clone_repo_regular =
                    `$(git) clone $(src_url) GITCLONEREPOREGULAR`
                @info(
                    "Attempting to run command",
                    cmd_git_clone_repo_regular,
                    pwd(),
                    )
                repo_regular_clone_was_success =
                    Utils.command_ran_successfully(
                    cmd_git_clone_repo_regular;
                    )
                if repo_regular_clone_was_success
                    @info("Command ran successfully",)
                    cd(
                        joinpath(
                            temp_dir_repo_git_clone_regular,
                            "GITCLONEREPOREGULAR",
                            )
                        )
                    grin_results::String = try
                        strip(read(`$(grin) Builder`, String))
                    catch exception
                        @info("ignoring exception: ", exception)
                        ""
                    end
                    list_of_new_src_dest_pairs::Vector{SrcDestPair} =
                        SrcDestPair[]
                    if length(grin_results) > 0
                        bin_bldr_pair_list::Vector{SrcDestPair} =
                            _get_list_of_binary_builder_repos(grin_results)
                        for bin_bldr_pair in bin_bldr_pair_list
                            if bin_bldr_pair in src_dest_pairs
                            else
                                push!(
                                    list_of_new_src_dest_pairs,
                                    bin_bldr_pair,
                                    )
                            end
                        end
                    end
                    if (length(grin_results) > 0) &&
                            (length(list_of_new_src_dest_pairs) > 0)
                        if length(list_of_new_src_dest_pairs) == 1
                            @info(
                                string(
                                    "I found ",
                                    "1 ",
                                    "additional repo to mirror. ",
                                    "I will mirror ",
                                    " it first, and then I will return ",
                                    "to my previous list.",
                                    )
                                )
                        else
                            @info(
                                string(
                                    "I found ",
                                    "$(length(list_of_new_src_dest_pairs)) ",
                                    "additional repos to mirror. ",
                                    "I will mirror ",
                                    " them first, and then I will return ",
                                    "to my previous list.",
                                    )
                                )
                        end
                        _push_mirrors(
                            list_of_new_src_dest_pairs,
                            github_organization,
                            github_user,
                            github_token;
                            recursion_level = recursion_level + 1,
                            max_recursion_depth = max_recursion_depth,
                            is_dry_run = is_dry_run,
                            do_not_try_url_list = do_not_try_url_list,
                            auth = auth,
                            do_not_push_to_these_destinations =
                                do_not_push_to_these_destinations,
                            try_but_allow_failures_url_list =
                                try_but_allow_failures_url_list,
                            )
                    else
                        @info(
                            string(
                                "I did not find any additional ",
                                "repos to mirror.",
                                )
                            )
                    end
                else
                    if src_url in try_but_allow_failures_url_list ||
                            _name_with_git(src_url) in
                                try_but_allow_failures_url_list ||
                            _name_without_git(src_url) in
                                try_but_allow_failures_url_list
                        @warn(
                            string(
                                "URL in the try-but-allow-failures list, ",
                                "so ignoring the error ",
                                "that occured while running command",
                                ),
                            cmd_git_clone_repo_regular,
                            pwd(),
                            )
                    else
                        error(
                            string(
                                "Encountered error when running command: ",
                                cmd_git_clone_repo_regular,
                                pwd(),
                                )
                            )
                    end
                end
            end
            cd(temp_dir_repo_git_clone_mirror)
            cmd_git_repo_clone_mirror =
                `$(git) clone --mirror $(src_url) GITCLONEREPOMIRROR`
            @info(
                "Attempting to run command",
                cmd_git_repo_clone_mirror,
                pwd(),
                )
            repo_mirror_clone_was_success =
                Utils.command_ran_successfully(
                cmd_git_repo_clone_mirror;
                )
            if repo_mirror_clone_was_success
                @info("Command ran successfully",)
                cd(
                    joinpath(
                        temp_dir_repo_git_clone_mirror,
                        "GITCLONEREPOMIRROR",
                        )
                    )
                @info("Processing the repository")
                packed_refs_filename = joinpath(
                    temp_dir_repo_git_clone_mirror,
                    "GITCLONEREPOMIRROR",
                    "packed-refs",
                    )
                _remove_problematic_refs_before_github(
                    ;
                    packed_refs_filename = packed_refs_filename,
                    )
                if destination_repo_name in
                        do_not_push_to_these_destinations ||
                        _name_with_git(destination_repo_name) in
                        do_not_push_to_these_destinations ||
                        _name_without_git(destination_repo_name) in
                        do_not_push_to_these_destinations ||
                        destination_repo_fullname in
                        do_not_push_to_these_destinations ||
                        _name_with_git(destination_repo_fullname) in
                        do_not_push_to_these_destinations ||
                        _name_without_git(destination_repo_fullname) in
                        do_not_push_to_these_destinations
                    @warn(
                        string(
                            "Destination repo is in the ",
                            "do-not-push-to-these-destinations list, ",
                            "therefore skipping push.",
                            ),
                        destination_repo_name,
                        destination_repo_fullname,
                        )
                else
                    mirrorpush_cmd_withauth =`$(git) push --mirror $(dest_url_withauth)`
                    mirrorpush_cmd_withredactedauth =`$(git) push --mirror $(dest_url_withredactedauth)`
                    if is_dry_run
                        @info(
                            string(
                                # "If this were not a dry run, I would now ",
                                # "run the following command: ",
                                "If this were not a dry run, ",
                                "I would now do the following 2 things: ",
                                "(1) I would make sure that the ",
                                "destination repo exists on GitHub, ",
                                "creating it if it does not already ",
                                "exist. (2) I would run the  ",
                                "\"git push --mirror\"",
                                "command.",
                                ),
                            github_organization,
                            destination_repo_name,
                            mirrorpush_cmd_withredactedauth,
                            pwd(),
                            )
                    else
                        @info(
                            string(
                                "Making sure the destination repo exists. ",
                                "If it does not exist, it will be created.",
                                ),
                            destination_repo_name,
                            )
                        _create_dest_repo_if_it_doesnt_exist(
                            pair,
                            github_organization,
                            github_user,
                            github_token;
                            auth = auth,
                            )
                        @info(
                            "Attempting to run command",
                            mirrorpush_cmd_withredactedauth,
                            pwd(),
                            )
                        mirrorpush_was_success =
                            Utils.command_ran_successfully(
                                mirrorpush_cmd_withauth;
                                )
                        if mirrorpush_was_success
                            @info("Command ran successfully",)
                        else
                            error(
                                string(
                                    "Command did not run successfully",
                                    cmd_withredactedauth,
                                    pwd(),
                                    )
                                )
                        end
                    end
                end
            else
                if src_url in try_but_allow_failures_url_list ||
                        _name_with_git(src_url) in
                            try_but_allow_failures_url_list ||
                        _name_without_git(src_url) in
                            try_but_allow_failures_url_list
                    @warn(
                        string(
                            "URL in the try-but-allow-failures list, ",
                            "so ignoring the error ",
                            "that occured while running command",
                            ),
                        cmd_git_repo_clone_mirror,
                        pwd(),
                        )
                else
                    error(
                        string(
                            "Encountered error when running command: ",
                            cmd_git_repo_clone_mirror,
                            pwd(),
                            )
                        )
                end
            end
            cd(previous_dir)
            rm(
                temp_dir_repo_git_clone_regular;
                force = true,
                recursive = true,
                )
            rm(
                temp_dir_repo_git_clone_mirror;
                force = true,
                recursive = true,
                )
        end
    end
    return nothing
end

function _get_list_of_binary_builder_repos(
        text::AbstractString,
        )::Vector{SrcDestPair}
    result::Vector{SrcDestPair} = SrcDestPair[]
    lines::Vector{String} = convert(
        Vector{String},
        split(strip(text), "\n"),
        )
    regex_1::Regex = r"https:\/\/github.com\/(\w*?)\/(\w*?)\/"
    for line in lines
        line_stripped::String = strip(line)
        if occursin(regex_1, line_stripped)
            regex_match::RegexMatch = match(regex_1, line_stripped)
            github_repo_owner::String = strip(regex_match[1])
            github_repo_name::String = strip(regex_match[2])
            source_url::String = string(
                "https://github.com/",
                github_repo_owner,
                "/",
                github_repo_name,
                )
            destination_repo_name::String = string(
                github_repo_owner,
                "-",
                github_repo_name,
                )
            new_pair = SrcDestPair(
                ;
                source_url = source_url,
                destination_repo_name = destination_repo_name,
                )
            push!(
                result,
                new_pair,
                )
        else
        end
    end
    return result
end

function _add_trailing_spaces(x::AbstractString, n::Integer)::String
    temp::String = strip(convert(String, x))
    if length(temp) >= n
        result::String = temp
    else
        deficit::Int = n - length(temp)
        result = string(temp, repeat(" ", deficit))
    end
    return result
end

function _interval_contains_x(
        interval::AbstractInterval,
        pair::SrcDestPair,
        )::Bool
    result::Bool = _interval_contains_x(interval, pair.destination_repo_name)
    return result
end

function _pairs_that_fall_in_interval(
        list_of_pairs::Vector{SrcDestPair},
        interval::AbstractInterval,
        )::Vector{SrcDestPair}
    ith_pair_falls_in_interval::Vector{Bool} = Vector{Bool}(
        undef,
        length(list_of_pairs),
        )
    for i = 1:length(list_of_pairs)
        ith_pair = list_of_pairs[i]
        ith_pair_falls_in_interval[i] = _interval_contains_x(
            interval,
            ith_pair,
            )
    end
    full_sublist::Vector{SrcDestPair} = list_of_pairs[
        ith_pair_falls_in_interval
        ]
    unique_sorted_sublist::Vector{SrcDestPair} = sort(unique(full_sublist))
    return unique_sorted_sublist
end

function _interval_contains_x(
        interval::TwoSidedInterval,
        x::AbstractString,
        )::Bool
    x_stripped::String = strip(convert(String, x))
    left::String = strip(interval.left)
    right::String = strip(interval.right)
    result::Bool = (left <= x_stripped) && (x_stripped < right)
    return result
end

function _interval_contains_x(
        interval::OneSidedInterval,
        x::AbstractString,
        )::Bool
    x_stripped::String = strip(convert(String, x))
    left::String = strip(interval.left)
    result::Bool = left <= x_stripped
    return result
end

function _get_git_binary_path(
        environment::Union{AbstractString,Symbol} =
            :unofficialjuliamirror_mirror_updater,
        )::String
    result::String = joinpath(
        Conda.bin_dir(environment),
        "git",
        )
    return result
end

function _get_grin_binary_path(
        environment::Union{AbstractString,Symbol} =
            :unofficialjuliamirror_mirror_updater,
        )::String
    result::String = joinpath(
        Conda.bin_dir(environment),
        "grin",
        )
    return result
end

##### End of file
