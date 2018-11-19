##### Beginning of file

module Run # Begin submodule MirrorUpdater.Run

__precompile__(true)

import ArgParse
import Dates
import HTTP
import Pkg
import TimeZones

import ..Types
import ..Utils
import ..Common

function run_mirror_updater!!(
        ;
        registry_list::Vector{Types.Registry},
        delete_gists_older_than_minutes::Int = 0,
        git_hosting_providers::AbstractVector =
            Any[],
        task::String =
            "all",
        gist_description::String =
            "",
        is_dry_run::Bool =
            false,
        additional_repos::Vector{Types.SrcDestPair} =
            Types.SrcDestPair[],
        do_not_push_to_these_destinations::Vector{String} =
            String[],
        do_not_try_url_list::Vector{String} =
            String[],
        try_but_allow_failures_url_list::Vector{String} =
            String[],
        time_zone::Dates.TimeZone =
            Dates.TimeZone("America/New_York"),
        )::Nothing
    @info("Running MirrorUpdater.Run.run_mirror_updater!!")

    if length(git_hosting_providers) == 0
        error(
            string(
                "You must supply at least one git hosting provider",
                )
            )
    elseif length(git_hosting_providers) == 1
        @info(
            string(
                "I will push to one git hosting provider.",
                ),
            )
    else
        @info(
            string(
                "I will push to $(length(git_hosting_providers)) ",
                "git hosting providers.",
                ),
            )
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
        @info(
            string(
                "The full list has ",
                "$(length(all_repos_to_mirror_stage1)) ",
                "unique pairs.",
                )
            )
        if has_gist_description
            for p in 1:length(git_hosting_providers)
                @info(
                    string(
                        "Git hosting provider ",
                        "$(p) of $(length(git_hosting_providers))",
                        ),
                    )
                provider = git_hosting_providers[p]
                @info(
                    string(
                        "Creating gist on git hosting provider $(p).",
                        )
                    )
                args = Dict(
                    :gist_description => gist_description,
                    :gist_content => gist_content_stage1,
                    )
                provider(:create_gist)(args)
            end
        end
        @info("SUCCESS: Stage 1 completed successfully.")
    end

    if task == "all" || Types._is_interval(task)
        @info("Starting stage 2...")
        if has_gist_description
            correct_gist_content_stage2::String = ""
            @info("looking for the correct gist")
            args = Dict(
                :gist_description => gist_description,
                )
            for p = 1:length(git_hosting_providers)
                @info(
                    string(
                        "Git hosting provider ",
                        "$(p) of $(length(git_hosting_providers))",
                        ),
                    )
                provider = git_hosting_providers[p]
                if length(correct_gist_content_stage2) == 0
                    @info(
                        string(
                            "Searching git hosting provider $(p) ",
                            "for the correct gist.",
                            )
                        )
                    correct_gist_content_stage2 = try
                        provider(:retrieve_gist)(args)
                    catch exception
                        @warn("Ignored exception", exception,)
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
        @info(
            string(
                "The full list has ",
                "$(length(all_repos_to_mirror_stage2)) ",
                "unique pairs.",
                )
            )
        if Types._is_interval(task)
            task_interval::Types.AbstractInterval =
                Types._construct_interval(task)
            @info(
                string("Using interval for stage 2: "),
                task_interval,
                )
            selected_repos_to_mirror_stage2 =
                Common._pairs_that_fall_in_interval(
                    all_repos_to_mirror_stage2,
                    task_interval,
                    )
        else
            selected_repos_to_mirror_stage2 =
                all_repos_to_mirror_stage2
        end
        @info(
            string(
                "The selected subset of the list ",
                "for this particular job has ",
                "$(length(selected_repos_to_mirror_stage2)) ",
                "unique pairs.",
                )
            )
        Common._push_mirrors!!(
            ;
            src_dest_pairs = selected_repos_to_mirror_stage2,
            git_hosting_providers = git_hosting_providers,
            is_dry_run = is_dry_run,
            do_not_try_url_list =
                do_not_try_url_list,
            try_but_allow_failures_url_list =
                try_but_allow_failures_url_list,
            do_not_push_to_these_destinations =
                do_not_push_to_these_destinations,
            time_zone = time_zone,
            )
        @info("SUCCESS: Stage 2 completed successfully.")
    end

    if task == "all" || task == "clean-up"
        @info("Starting stage 3...")
        if has_gist_description
            args = Dict(
                :gist_description => gist_description
                )
            for p = 1:length(git_hosting_providers)
                @info(
                    string(
                        "Git hosting provider ",
                        "$(p) of $(length(git_hosting_providers))",
                        ),
                    )
                provider = git_hosting_providers[p]
                @info(
                    string(
                        "Deleting gists from git hosting provider $(p) ",
                        "that match the provided ",
                        "gist description.",
                        ),
                    gist_description,
                    )
                try
                    provider(:delete_gists)(args)
                catch exception
                    @warn("ignoring exception: ", exception)
                end
            end
        end

        if delete_gists_older_than_minutes > 0
            time::TimeZones.ZonedDateTime = Dates.now(
                TimeZones.localzone()
                )
            args = Dict(
                :delete_gists_older_than_minutes =>
                    delete_gists_older_than_minutes,
                :time =>
                    time,
                )
            for p = 1:length(git_hosting_providers)
                provider = git_hosting_providers[p]
                @info(
                    string(
                        "Deleting gists from git hosting provider $(p) ",
                        "that are older than the provided ",
                        "age in minutes.",
                        ),
                    delete_gists_older_than_minutes,
                    )
                try
                    provider(:delete_gists_older_than_minutes)(args)
                catch exception
                    @warn("ignoring exception: ", exception)
                end
            end
        end
        @info("SUCCESS: Stage 3 completed successfully.")
    end

    @info(
        string(
            "SUCCESS: run_mirror_updater completed ",
            "successfully :) Good-bye!",
            )
        )

    return nothing
end

end # End submodule MirrorUpdater.Run

##### End of file
