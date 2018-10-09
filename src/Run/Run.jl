##### Beginning of file

module Run # Begin submodule MirrorUpdater.Run

__precompile__(true)

import ArgParse
import Conda
import Dates
import HTTP
import Pkg
import TimeZones

import ..Types
import ..Utils
import ..Common

function run_mirror_updater!!(
        ;
        git_hosting_providers::AbstractVector = [],
        task::String,
        gist_description::String,
        is_dry_run::Bool,
        registry_list::Vector{Types.Registry},
        additional_repos::Vector{Types.SrcDestPair},
        do_not_push_to_these_destinations::Vector{String},
        do_not_try_url_list::Vector{String},
        try_but_allow_failures_url_list::Vector{String},
        time_zone::Dates.TimeZone = Dates.TimeZone("America/New_York"),
        )::Nothing
    @info("Running MirrorUpdater.Run.run_mirror_updater!!")

    enabled_git_hosting_providers::Vector{Symbol} = Symbol[]
    git_hosting_providers_params::Dict{Symbol, Dict} = Dict{Symbol, Dict}()
    git_hosting_providers_functions::Dict{Symbol, Dict{Symbol, Function}} =
        Dict{Symbol, Dict{Symbol, Function}}()

    if github_enabled
        @info("Authenticating to GitHub...")



        git_hosting_providers_params[:github] = Dict{Symbol, Any}()
        git_hosting_providers_params[:github][:my_github_auth] =
            my_github_auth
        git_hosting_providers_params[:github][:github_organization] =
            github_organization
        git_hosting_providers_params[:github][:github_token] =
            github_token
        git_hosting_providers_params[:github][:github_user] =
            github_user

        git_hosting_providers_functions[:github] = Dict{Symbol, Function}()
        git_hosting_providers_functions[:github][
            :create_gist!!] = GitHubHost._github_create_gist!!
        git_hosting_providers_functions[:github][
            :retrieve_gist] = GitHubHost._github_retrieve_gist
        git_hosting_providers_functions[:github][
            :delete_gists!!] = GitHubHost._github_delete_gists!!
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        git_hosting_providers_functions[:github][
            :] = GitHubHost.
        push!(enabled_git_hosting_providers, :github)
    end

    if gitlab_enabled
        error("GitLab is not yet supported.")

        git_hosting_providers_params[:gitlab] = Dict{Symbol, Any}()

        git_hosting_providers_functions[:gitlab] = Dict{Symbol, Function}()

        push!(enabled_git_hosting_providers, :gitlab)
    end

    if length(enabled_git_hosting_providers) == 0
        error("You must enable at least one Git hosting provider")
    end

    has_gist_description::Bool = length(gist_description) > 0

    if task == "all" || task == "make-list"
        @info("Starting stage 1...")
        @info("Making list of repos to mirror...")

        all_repos_to_mirror_stage1::Vector{Types.SrcDestPair} =
            Common._make_list(
                registry_list,
                additional_repos;
                do_not_try_url_list =
                    do_not_try_url_list,
                try_but_allow_failures_url_list =
                    try_but_allow_failures_url_list,
                )
        gist_content_stage1::String = Common._src_dest_pair_list_to_string(
            all_repos_to_mirror_stage1
            )
        if has_gist_description
            args = Dict(
                :gist_description => gist_description,
                :gist_content_stage1 => gist_content_stage1,
                )
            for host in enabled_git_hosting_providers
                git_hosting_providers_functions[host][:create_gist!!](
                    ;
                    args = args,
                    host_params = git_hosting_providers_params[host],
                    )
            end
        end
        @info("Stage 1 completed successfully.")
    end

    if task == "all" || Types._is_interval(task)
        @info("Starting stage 2...")
        if has_gist_description
            correct_gist_content_stage2::String = ""
            @info("looking for the correct gist")
            args = Dict(
                :gist_description => gist_description,
                )
            for host in enabled_git_hosting_providers
                if length(strip(correct_gist_content_stage2)) == 0
                    correct_gist_content_stage2 = try
                        git_hosting_providers_functions[host][
                            :retrieve_gist](
                                ;
                                args=args,
                                host_params=
                                    git_hosting_providers_params[host],
                                )
                    catch exception
                        @warn("ignoring exception: ",exception,)
                        ""
                    end
                end
            end
            if length(strip(correct_gist_content_stage2)) == 0
                error("I could not find the correct gist on any host")
            end
            all_repos_to_mirror_stage2 =
                Common._string_to_src_dest_pair_list(
                    correct_gist_content_stage2
                    )
        else
            @info("no need to download any gists: I already have the list")
            all_repos_to_mirror_stage2 =
                all_repos_to_mirror_stage1
        end
        if Types._is_interval(task)
            task_interval::Types.AbstractInterval =
                Types._construct_interval(task)
            @info(
                string("Using interval for stage 2: "),
                task_interval,
                )
            selected_repos_to_mirror_stage2 =
                _pairs_that_fall_in_interval(
                    all_repos_to_mirror_stage2,
                    task_interval,
                    )
        else
            selected_repos_to_mirror_stage2 =
                all_repos_to_mirror_stage2
        end
        Common._push_mirrors!!(
            ;
            src_dest_pairs = selected_repos_to_mirror_stage2,
            enabled_git_hosting_providers = enabled_git_hosting_providers,
            git_hosting_providers_params = git_hosting_providers_params,
            git_hosting_providers_functions =
                git_hosting_providers_functions,
            is_dry_run = is_dry_run,
            auth = my_github_auth,
            do_not_try_url_list =
                do_not_try_url_list,
            try_but_allow_failures_url_list =
                try_but_allow_failures_url_list,
            do_not_push_to_these_destinations =
                do_not_push_to_these_destinations,
            time_zone = time_zone,
            )
        @info("Stage 2 completed successfully.")
    end

    if task == "all" || task == "clean-up"
        @info("Starting stage 3...")
        if has_gist_description
            args = Dict(
                :gist_description => gist_description
                )
            for host in enabled_git_hosting_providers
                git_hosting_providers_functions[host][:delete_gists!!](
                    ;
                    args = args,
                    host_params = git_hosting_providers_params[host],
                    )
            end
        end
        @info("Stage 3 completed successfully.")
    end

    @info("run_mirror_updater completed successfully :)")

    return nothing
end

end # End submodule MirrorUpdater.Run

##### End of file
