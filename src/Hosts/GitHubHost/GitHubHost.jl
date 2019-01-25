##### Beginning of file

module GitHubHost # Begin submodule MirrorUpdater.Hosts.GitHubHost

__precompile__(true)

import ..Types
import ..Utils

import Dates
import GitHub
import TimeZones

function new_github_session(
        ;
        github_organization::AbstractString,
        github_bot_username::AbstractString,
        github_bot_personal_access_token::AbstractString,
        )::Function

    _github_organization::String = strip(
        convert(String, github_organization)
        )
    _provided_github_bot_username::String = strip(
        convert(String, github_bot_username,)
        )
    _github_bot_personal_access_token::String = strip(
        convert(String, github_bot_personal_access_token)
        )
    function _get_github_username(auth::GitHub.Authorization)::String
        user_information::AbstractDict = GitHub.gh_get_json(
            GitHub.DEFAULT_API,
            "/user";
            auth = auth,
            )
        username::String = user_information["name"]
        username_stripped::String = strip(username)
        return username_stripped
    end

    @info("Attempting to authenticate to GitHub...")
    auth::GitHub.Authorization = GitHub.authenticate(
        _github_bot_personal_access_token
        )
    _github_username::String = _get_github_username(auth)
    if lowercase(strip(_github_username)) !=
            lowercase(strip(_provided_github_bot_username))
        error(
            string(
                "Provided GitHub username ",
                "(\"$(_provided_github_bot_username)\") ",
                "does not match ",
                "actual GitHub username ",
                "(\"$(_github_username)\").",
                )
            )
    else
        @info(
            string(
                "Provided GitHub username matches ",
                "actual GitHub username.",
                ),
            _provided_github_bot_username,
            _github_username,
            )
    end
    @info("Successfully authenticated to GitHub :)")

    @info(
        string(
            "GitHub username: ",
            "$(_get_github_username(auth))",
            )
        )
    @info(
        string(
            "GitHub organization: ",
            "$(_github_organization)",
            )
        )

    repository_owner = GitHub.owner(
        _github_organization,
        true;
        auth = auth,
        )

    function _create_gist(params::AbstractDict)::Nothing
        gist_description::String = strip(params[:gist_description])
        gist_content::String = strip(params[:gist_content])
        @info("Attempting to create gist on GitHub...")
        create_gist_function = () ->
            GitHub.create_gist(
                ;
                auth = auth,
                params = Dict(
                    :public => true,
                    :description => gist_description,
                    :files => Dict(
                        "list.txt" => Dict("content" => gist_content,),
                        ),
                    ),
                )
        Utils.retry_function_until_success(
            create_gist_function;
            max_attempts = 10,
            seconds_to_wait_between_attempts = 180,
            )
        @info("Successfully created gist on GitHub.")
        return nothing
    end

    function _get_all_gists()::Vector{GitHub.Gist}
        @info("Loading the list of all of my GitHub gists")
        full_gist_list::Vector{GitHub.Gist} = GitHub.Gist[]
        need_to_continue::Bool = true
        current_page_number::Int = 1
        while need_to_continue
            gists, page_data = GitHub.gists(
                _github_username;
                params = Dict(
                    "per_page" => 100,
                    "page" => current_page_number,
                    ),
                auth = auth,
                )
            if length(gists) == 0
                need_to_continue = false
            else
                for x in gists
                    if x in full_gist_list
                    else
                        push!(full_gist_list, x)
                    end
                end
                need_to_continue = true
                current_page_number += 1
            end
        end
        unique_gist_list::Vector{GitHub.Gist} = unique(full_gist_list)
        return unique_gist_list
    end

    function _retrieve_gist(params::AbstractDict)::String
        gist_description_to_match::String = params[:gist_description]
        correct_gist_id::String = ""
        all_my_gists = _get_all_gists()
        for gist in all_my_gists
            if gist.description == gist_description_to_match
                correct_gist_id = gist.id
            end
        end
        result::String = ""
        if length(correct_gist_id) > 0
            @info("Downloading the correct GitHub gist")
            correct_gist::GitHub.Gist = GitHub.gist(
                correct_gist_id;
                auth = auth,
                )
            correct_gist_content::String = correct_gist.files[
                "list.txt"]["content"]
            result = correct_gist_content
        else
            result = ""
        end
        if length(result) == 0
            error("Could not find the matching Gist")
        end
        return result
    end

    function _delete_gists(params::AbstractDict)::Nothing
        gist_description_to_match::String = params[:gist_description]
        list_of_gist_ids_to_delete::Vector{String} = String[]
        all_my_gists::Vector{GitHub.Gist} = _get_all_gists()
        for gist in all_my_gists
            if gist.description == gist_description_to_match
                push!(list_of_gist_ids_to_delete, strip(gist.id),)
            end
        end
        for gist_id_to_delete in list_of_gist_ids_to_delete
            GitHub.delete_gist(gist_id_to_delete;auth = auth,)
            @info(string("Deleted GitHub gist id $(gist_id_to_delete)"))
        end
        return nothing
    end

    function _delete_gists_older_than_minutes(params::AbstractDict)::Nothing
        time::TimeZones.ZonedDateTime =
            params[:time]
        delete_gists_older_than_minutes::Int =
            params[:delete_gists_older_than_minutes]
        max_gist_age_milliseconds::Int =
            delete_gists_older_than_minutes*60*1000
        list_of_gist_ids_to_delete::Vector{String} = String[]
        all_my_gists::Vector{GitHub.Gist} = _get_all_gists()
        for gist in all_my_gists
            gist_updated_at = gist.updated_at
            gist_updated_at_zoned = TimeZones.ZonedDateTime(
                gist_updated_at,
                TimeZones.localzone(),
                )
            gist_age = time - gist_updated_at_zoned
            if gist_age.value > max_gist_age_milliseconds
                push!(list_of_gist_ids_to_delete, strip(gist.id),)
            end
        end
        for gist_id_to_delete in list_of_gist_ids_to_delete
            GitHub.delete_gist(gist_id_to_delete;auth = auth,)
            @info(string("Deleted GitHub gist id $(gist_id_to_delete)"))
        end
        return nothing
    end

    function _repo_name_with_org(
            ;
            repo::AbstractString,
            org::AbstractString,
            )::String
        repo_name_without_org::String = _repo_name_without_org(
            ;
            repo = repo,
            org = org,
            )
        org_stripped::String = strip(
            strip(strip(strip(strip(convert(String, org)), '/')), '/')
            )
        result::String = string(
            org_stripped,
            "/",
            repo_name_without_org,
            )
        return result
    end

    function _repo_name_without_org(
            ;
            repo::AbstractString,
            org::AbstractString,
            )::String
        repo_stripped::String = strip(
            strip(strip(strip(strip(convert(String, repo)), '/')), '/')
            )
        org_stripped::String = strip(
            strip(strip(strip(strip(convert(String, org)), '/')), '/')
            )
        if length(org_stripped) == 0
            result = repo_stripped
        else
            repo_stripped_lowercase::String = lowercase(repo_stripped)
            org_stripped_lowercase::String = lowercase(org_stripped)
            org_stripped_lowercase_withtrailingslash::String = string(
                org_stripped_lowercase,
                "/",
                )
            if startswith(repo_stripped_lowercase,
                    org_stripped_lowercase_withtrailingslash)
                index_start =
                    length(org_stripped_lowercase_withtrailingslash) + 1
                result = repo_stripped[index_start:end]
            else
                result = repo_stripped
            end
        end
        return result
    end

    function _get_destination_url(
            ;
            repo_name::String,
            credentials::Symbol,
            )::String
        repo_name_without_org::String = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _github_organization,
            )
        result::String = ""
        if credentials == :with_auth
            result = string(
                "https://",
                _github_username,
                ":",
                _github_bot_personal_access_token,
                "@",
                "github.com/",
                _github_organization,
                "/",
                repo_name_without_org,
                )
        elseif credentials == :with_redacted_auth
            result = string(
                "https://",
                _github_username,
                ":",
                "*****",
                "@",
                "github.com/",
                _github_organization,
                "/",
                repo_name_without_org,
                )
        elseif credentials == :without_auth
            result =string(
                "https://",
                "github.com/",
                _github_organization,
                "/",
                repo_name_without_org,
                )
        else
            error("$(credentials) is not a supported value for credentials")
        end
        return result
    end

    function _github_repo_exists(
            ;
            repo_name::String,
            )::Bool
        repo_name_with_org = _repo_name_with_org(
            ;
            repo = repo_name,
            org = _github_organization,
            )
        result::Bool = try
            repo = GitHub.repo(
                repo_name_with_org;
                auth = auth,
                )
            true
        catch
            false
        end
        return result
    end

    function _create_repo(params::AbstractDict)::Nothing
        repo_name::String = params[:repo_name]
        repo_name_with_org::String = _repo_name_with_org(
            ;
            repo = repo_name,
            org = _github_organization,
            )
        repo_name_without_org::String = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _github_organization,
            )
        repo_destination_url_without_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :without_auth,
            )
        if Utils._url_exists(repo_destination_url_without_auth)
            @info("According to HTTP GET request, the repo exists.")
        else
            if _github_repo_exists(; repo_name = repo_name_with_org)
                @info("According to the GitHub API, the repo exists.")
            else
                @info(
                    string("Creating new repo on GitHub"),
                    repo_destination_url_without_auth,
                    )
                repo = GitHub.create_repo(
                    repository_owner,
                    repo_name_without_org,
                    Dict{String, Any}(
                        "has_issues" => "false",
                        "has_wiki" => "false",
                        );
                    auth = auth,
                    )
            end
        end
        return nothing
    end

    function _push_mirrored_repo(params::AbstractDict)::Nothing
        repo_name::String = params[:repo_name]
        repo_directory::String = params[:directory]
        git_path::String = params[:git]
        try_but_allow_failures_url_list =
            params[:try_but_allow_failures_url_list]
        repo_name_without_org = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _github_organization,
            )
        repo_dest_url_without_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :without_auth,
            )
        repo_dest_url_with_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :with_auth,
            )
        repo_dest_url_with_redacted_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :with_redacted_auth,
            )
        previous_directory = pwd()
        cd(repo_directory)
        mirrorpush_cmd_withauth =
            `$(git_path) push --mirror $(repo_dest_url_with_auth)`
        mirrorpush_cmd_withredactedauth =
            `$(git_path) push --mirror $(repo_dest_url_with_redacted_auth)`
        @info(
            string("Attempting to push repo to GitHub..."),
            mirrorpush_cmd_withredactedauth,
            pwd(),
            ENV["PATH"],
            )
        try
            Utils.command_ran_successfully!!(
                mirrorpush_cmd_withauth;
                error_on_failure = true,
                last_resort_run = true,
                )
            @info(
                string("Successfully pushed repo to GitHub."),
                mirrorpush_cmd_withredactedauth,
                pwd(),
                ENV["PATH"],
                )
        catch exception
            @warn("caught exception: ", exception)
            if repo_dest_url_without_auth in try_but_allow_failures_url_list
                @warn(
                    string(
                        "repo_dest_url_without_auth is in the ",
                        "try_but_allow_failures_url_list, so ignoring ",
                        "exception.",
                        ),
                    repo_dest_url_without_auth,
                    exception,
                    )
            else
                rethrow(exception)
            end
        end
        cd(previous_directory)
        return nothing
    end

    function _generate_new_repo_description(
            params::AbstractDict,
            )::String
        source_url::String = params[:source_url]
        when::TimeZones.ZonedDateTime = params[:when]
        time_zone::TimeZones.TimeZone = params[:time_zone]
        by::String = strip(string("@", _github_username))

        new_description::String = Utils.default_repo_description(
            ;
            from = source_url,
            when = when,
            time_zone = time_zone,
            by = by,
            )

        return new_description
    end

    function _update_repo_description(params::AbstractDict)::Nothing
        repo_name::String = params[:repo_name]
        new_repo_description = params[:new_repo_description]
        _create_repo(
            Dict(
                :repo_name => repo_name,
                ),
            )
        repo_name_with_org::String = _repo_name_with_org(
            ;
            repo = repo_name,
            org = _github_organization,
            )
        github_repo_function = () -> GitHub.repo(
            repo_name_with_org;
            auth = auth,
            )
        repo = Utils.retry_function_until_success(
            github_repo_function;
            max_attempts = 10,
            seconds_to_wait_between_attempts = 180,
            )
        @info("Attempting to update repo description on GitHub...")
        github_update_description_function = () ->
            GitHub.gh_patch_json(
                GitHub.DEFAULT_API,
                "/repos/$(GitHub.name(repo.owner))/$(GitHub.name(repo.name))";
                auth = auth,
                params = Dict(
                    "name" => GitHub.name(repo.name),
                    "description" => new_repo_description,
                    ),
                )
        result = Utils.retry_function_until_success(
            github_update_description_function;
            max_attempts = 10,
            seconds_to_wait_between_attempts = 180,
            )
        @info("Successfully updated repo description on GitHub")
        return nothing
    end

    function _github_provider(task::Symbol)::Function
        if task == :create_gist
            return _create_gist
        elseif task == :retrieve_gist
            return _retrieve_gist
        elseif task == :delete_gists
            return _delete_gists
        elseif task == :create_repo
            return _create_repo
        elseif task == :push_mirrored_repo
            return _push_mirrored_repo
        elseif task == :generate_new_repo_description
            return _generate_new_repo_description
        elseif task == :update_repo_description
            return _update_repo_description
        elseif task == :delete_gists_older_than_minutes
            return _delete_gists_older_than_minutes
        else
            error("$(task) is not a valid task")
        end
    end

    return _github_provider
end

end # End submodule MirrorUpdater.Hosts.GitHubHost

##### End of file
