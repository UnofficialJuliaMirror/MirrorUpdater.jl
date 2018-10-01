##### Beginning of file

import ArgParse
import Conda
import GitHub
import HTTP
import Pkg

function run_mirror_updater( # this is the main method
        ;
        arguments::Vector{String},
        github_organization::String,
        github_user::String,
        github_token::String,
        registry_list::Vector{Registry},
        additional_repos::Vector{SrcDestPair},
        do_not_push_to_these_destinations::Vector{String},
        do_not_try_url_list::Vector{String},
        try_but_allow_failures_url_list::Vector{String},
        )::Nothing

    @info("parsing command line arguments...")
    parsed_arguments::Dict = _parse_arguments(arguments)

    @info("Authenticating to GitHub...")
    my_github_auth::GitHub.Authorization = GitHub.authenticate(
        github_token
        )

    task,
        has_gist_description,
        gist_description,
        is_dry_run, = _process_parsed_arguments(parsed_arguments)

    if task == "all" || task == "make-list"
        @info("Starting stage 1...")
        @info("Making list of repos to mirror...")

        all_repos_to_mirror_stage1::Vector{SrcDestPair} = _make_list(
            registry_list,
            additional_repos;
            do_not_try_url_list =
                do_not_try_url_list,
            try_but_allow_failures_url_list =
                try_but_allow_failures_url_list,
            )
        gist_content_stage1::String = _src_dest_pair_list_to_string(
            all_repos_to_mirror_stage1
            )
        if has_gist_description
            @info("Making gist on GitHub...")
            GitHub.create_gist(
                ;
                auth = my_github_auth,
                params = Dict(
                    :public => true,
                    :description => gist_description,
                    :files => Dict(
                        "list.txt" => Dict(
                            "content" => gist_content_stage1,
                            ),
                        ),
                    ),
                )
        end
        @info("Stage 1 completed successfully.")
    end

    if task == "all" || _is_interval(task)
        @info("Starting stage 2...")
        if has_gist_description
            correct_gist_id::String = ""
            @info("loading all of my gists")
            my_gists_stage2::Vector{GitHub.Gist} = GitHub.gists(
                github_user;
                auth = my_github_auth,
                )[1]
            for gist in my_gists_stage2
                if gist.description == gist_description
                    correct_gist_id = gist.id
                end
            end
            if length(correct_gist_id) > 0
                @info("downloading the correct gist")
                correct_gist::GitHub.Gist = GitHub.gist(
                    correct_gist_id;
                    auth = my_github_auth,
                    )
                correct_gist_content_stage2::String = correct_gist.files[
                    "list.txt"][
                    "content"]
                all_repos_to_mirror_stage2 =
                    _string_to_src_dest_pair_list(
                        correct_gist_content_stage2
                        )
            else
                error("could not find the correct gist!")
            end
        else
            @info("no need to download any gists: I already have the list")
            all_repos_to_mirror_stage2 =
                all_repos_to_mirror_stage1
        end
        if _is_interval(task)
            task_interval::AbstractInterval = _construct_interval(task)
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
        _push_mirrors(
            selected_repos_to_mirror_stage2,
            github_organization,
            github_user,
            github_token;
            is_dry_run = is_dry_run,
            auth = my_github_auth,
            do_not_try_url_list =
                do_not_try_url_list,
            try_but_allow_failures_url_list =
                try_but_allow_failures_url_list,
            do_not_push_to_these_destinations =
                do_not_push_to_these_destinations,
            )
        @info("Stage 2 completed successfully.")
    end

    if task == "all" || task == "clean-up"
        @info("Starting stage 3...")
        if has_gist_description
            list_of_gist_ids_to_delete::Vector{String} = String[]
            @info("loading all my gists")
            my_gists_stage3::Vector{GitHub.Gist} = GitHub.gists(
                github_user;
                auth = my_github_auth,
                )[1]
            for gist in my_gists_stage3
                if gist.description == gist_description
                    push!(list_of_gist_ids_to_delete, gist.id)
                end
            end
            for gist_id_to_delete in list_of_gist_ids_to_delete
                @info(string("deleting gist id $(gist_id_to_delete)"))
                GitHub.delete_gist(
                    gist_id_to_delete;
                    auth = my_github_auth,
                    )
            end
        end
        @info("Stage 3 completed successfully.")
    end

    @info("run_mirror_updater completed successfully :)")

    return nothing
end

##### End of file
