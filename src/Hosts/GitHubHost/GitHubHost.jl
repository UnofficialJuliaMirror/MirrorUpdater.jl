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
        github_organization::String,
        github_token::String,
        )::Function

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
    auth::GitHub.Authorization = GitHub.authenticate(github_token)
    github_user::String = Hosts.GitHubHost._get_github_username(
        my_github_auth,
        )
    @info("Successfully authenticated to GitHub")

    repository_owner = GitHub.owner(
        github_org,
        true;
        auth = auth,
        )

    function _create_gist(params::Dict{Symbol, Any})::Nothing
        gist_description::String = params[:gist_description]
        gist_content::String = args[:gist_content]
        @info("Attempting to create gist on GitHub...")
        GitHub.create_gist(
            ;
            auth = auth,
            params = Dict(
                :public => true,
                :description => gist_description,
                :files => Dict(
                    "list.txt" => Dict(
                        "content" => gist_content,
                        ),
                    ),
                ),
            )
        @info("Successfully created gist on GitHub.")
        return nothing
    end

    function _retrieve_gist(params::Dict{Symbol, Any})::String
        gist_description::String = params[:gist_description]
        @info("Loading the list of all of my GitHub gists")
        my_gists::Vector{GitHub.Gist} = GitHub.gists(github_user;auth = auth,)[1]
        correct_gist_id::String = ""
        for gist in my_gists
            if gist.description == gist_description
                correct_gist_id = gist.id
            end
        end
        result::String = ""
        if length(correct_gist_id) > 0
            @info("Downloading the correct GitHub gist")
            correct_gist::GitHub.Gist = GitHub.gist(
                correct_gist_id;
                auth = my_github_auth,
                )
            correct_gist_content::String = correct_gist.files[
                "list.txt"]["content"]
            result = correct_gist_content
        else
            result = ""
        end
        return result
    end

    function _delete_gists(params::Dict{Symbol, Any})::Nothing
        gist_description::String = params[:gist_description]
        list_of_gist_ids_to_delete::Vector{String} = String[]
        @info("Loading the list of all of my GitHub gists")
        my_gists::Vector{GitHub.Gist} = GitHub.gists(
            github_user;
            auth = auth,)[1]
        for gist in my_gists
            if gist.description == gist_description
                push!(list_of_gist_ids_to_delete, gist.id)
            end
        end
        for gist_id_to_delete in list_of_gist_ids_to_delete
            GitHub.delete_gist(gist_id_to_delete;auth = my_github_auth,)
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
            org = github_org,
            )
        result::String = ""
        if credentials == :with_auth
            result = string(
                "https://",
                github_user,
                ":",
                github_token,
                "@",
                "github.com/",
                github_org,
                "/",
                repo_name_without_org,
                )
        elseif credentials == :with_redacted_auth
            result = string(
                "https://",
                github_user,
                ":",
                "*****",
                "@",
                "github.com/",
                github_org,
                "/",
                repo_name_without_org,
                )
        elseif credentials == :without_auth
            result =string(
                "https://",
                "github.com/",
                github_org,
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
            org = github_org,
            )
        result:::Bool = try
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

    function _create_repo(params::Dict{Symbol, Any})::Nothing
        repo_name::String = params[:repo_name]
        repo_name_with_org::String = _repo_name_with_org(
            ;
            repo = repo_name,
            org = github_org,
            )
        repo_name_without_org::String = _repo_name_without_org(
            ;
            repo = repo_name,
            org = github_org,
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

    function _push_mirrored_repo(params::Dict{Symbol, Any})::Nothing
        repo_name::String = params[:repo_name]
        repo_directory::String = params[:directory]
        git_path::String = params[:git_path]
        repo_destination_url_with_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :with_auth,
            )
        repo_destination_url_with_redacted_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :with_redacted_auth,
            )
        previous_directory = pwd()
        cd(directory)
        mirrorpush_cmd_withauth =
            `$(git_path) push --mirror $(dest_url_withauth)`
        mirrorpush_cmd_withredactedauth =
            `$(git_path) push --mirror $(dest_url_withredactedauth)`
        @info(
            string("Attempting to push repo to GitHub..."),
            mirrorpush_cmd_withredactedauth,
            pwd(),
            ENV["PATH"],
            )
        mirrorpush_was_success = try
            command_ran_successfully!!(mirrorpush_cmd_withauth)
        catch exception
            @warn("Ignoring exception: ", exception)
            false
        end
        if mirrorpush_was_success
            @info("Successfully pushed repo to GitHub...")
        else
            error("An error occured while attempting to push to GitHub...")
        end
        @info(string("Push to GitHub was successful."))
        cd(previous_directory)
        return nothing
    end

    function _generate_new_repo_description(
            params::Dict{Symbol, Any},
            )::Nothing

        source_url::String = params[:source_url]

        when::TimeZones.ZonedDateTime = params[:when] # Dates.now(TimeZones.localzone()),
        time_zone::Dates.TimeZone = params[:time_zone] # TimeZones.TimeZone("America/New_York")
        date_time_string = string(TimeZones.astimezone(when,time_zone,))

        via_travis::String = ""
        if Utils._is_travis_ci()
            travis_event_type::String = strip(
                get(a, "TRAVIS_EVENT_TYPE", "")
                )
            if length(travis_event_type) > 0
                travis_event_string = string(" $(travis_event_type)")
            else
                travis_event_string = string("")
            end
            travis_build_number::String = strip(
                get(a, "TRAVIS_BUILD_NUMBER", "")
                )
            travis_job_number::String = strip(
                get(a, "TRAVIS_JOB_NUMBER", "")
                )
            if length(travis_job_number) > 0
                travis_number_string = string(" (job $(travis_job_number))")
            elseif length(travis_build_number) > 0
                travis_number_string = string(" (build $(travis_build_number))")
            else
                travis_number_string = string("")
            end
            via_travis = string(
                " via Travis",
                travis_event_string,
                travis_number_string,
                )
        else
            via_travis = ""
        end

        new_description::String = string(
            "Mirrored from $(source_url) on ",
            date_time_string,
            " by @$(github_user)",
            via_travis,
            )

        return new_description
    end

    function _update_repo_description(params::Dict{Symbol, Any})::Nothing
        repo_name::String = params[:repo_name]
        new_repo_description = params[:new_repo_description]
        _create_repo(
            ;
            repo_name = repo_name,
            )
        repo_name_with_org::String = _repo_name_with_org(
            ;
            repo = repo_name,
            org = github_org,
            )
        repo = GitHub.repo(repo_name_with_org; auth = auth,)
        result = GitHub.gh_patch_json(
            GitHub.DEFAULT_API,
            "/repos/$(GitHub.name(repo.owner))/$(GitHub.name(repo.name))";
            auth = auth,
            params = Dict(
                "name" => GitHub.name(repo.name),
                "description" => new_repo_description,
                ),
            )
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
        else
            error("$(task) is not a valid task")
        end
    end

    return _github_provider
end

end # End submodule MirrorUpdater.Hosts.GitHubHost

##### End of file
