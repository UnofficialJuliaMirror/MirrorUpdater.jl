##### Beginning of file

module BitbucketHost # Begin submodule MirrorUpdater.Hosts.BitbucketHost

__precompile__(true)

import ..Types
import ..Utils

import Dates
import HTTP
import JSON
import TimeZones

function new_bitbucket_session(
        ;
        bitbucket_team::String,
        bitbucket_bot_username::String,
        bitbucket_bot_app_password::String,
        )::Function

    _bitbucket_team::String = strip(
        convert(String, bitbucket_team)
        )
    _alleged_bitbucket_bot_username::String = strip(
        convert(String, bitbucket_bot_username)
        )
    _bitbucket_bot_app_password::String = strip(
        convert(String, bitbucket_bot_app_password)
        )

    function _get_bitbucket_username_from_alleged()::String
        method::String = "GET"
        url::String = string(
            "https://",
            "$(_alleged_bitbucket_bot_username)",
            ":",
            "$(_bitbucket_bot_app_password)",
            "@api.bitbucket.org",
            "/2.0",
            "/user",
            )
        r::HTTP.Messages.Response = HTTP.request(
            method,
            url;
            basic_authorization = true
            )
        r_body::String = String(r.body)
        parsed_body::Dict = JSON.parse(r_body)
        username::String = parsed_body["username"]
        username_stripped::String = strip(username)
        return username_stripped
    end

    @info("Attempting to authenticate to Bitbucket...")
    _bitbucket_username::String = _get_bitbucket_username_from_alleged()
    @debug(
        string("Provided username vs. actual username: "),
        _alleged_bitbucket_bot_username,
        _bitbucket_username,
        )
    if lowercase(strip(_bitbucket_username)) !=
            lowercase(strip(_alleged_bitbucket_bot_username))
        @warn(
            string(
                "lowercase(strip(_bitbucket_username)) != ",
                "lowercase(strip(_alleged_bitbucket_bot_username))",
                ),
            _bitbucket_username,
            _alleged_bitbucket_bot_username,
            )
        error(
            string(
                "lowercase(strip(_bitbucket_username)) != ",
                "lowercase(strip(_alleged_bitbucket_bot_username))",
                )
            )
    end
    @info("Successfully authenticated to Bitbucket")

    @info(
        string(
            "Bitbucket username: ",
            "$(_get_bitbucket_username_from_alleged())",
            )
        )
    @info(
        string(
            "Bitbucket team (a.k.a. organization): ",
            "$(_bitbucket_team)",
            )
        )

    function _create_gist(params::AbstractDict)::Nothing
        @warn(
            string(
                "At this time, snippet (a.k.a. gist) ",
                "functionality is not yet supported ",
                "for the Bitbucket backend.",
                )
            )
        return nothing
    end

    function _retrieve_gist(params::AbstractDict)::String
        @warn(
            string(
                "At this time, snippet (a.k.a. gist) ",
                "functionality is not yet supported ",
                "for the Bitbucket backend.",
                )
            )
        error("Could not find the matching Bitbucket snippet")
    end

    function _delete_gists(params::AbstractDict)::Nothing
        @warn(
            string(
                "At this time, snippet (a.k.a. gist) ",
                "functionality is not yet supported ",
                "for the Bitbucket backend.",
                )
            )
        return nothing
    end

    function _delete_gists_older_than_minutes(params::AbstractDict)::Nothing
        @warn(
            string(
                "At this time, snippet (a.k.a. gist) ",
                "functionality is not yet supported ",
                "for the Bitbucket backend.",
                )
            )
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
            org = _bitbucket_team,
            )
        result::String = ""
        if credentials == :with_auth
            result = string(
                "https://",
                _bitbucket_username,
                ":",
                _bitbucket_bot_app_password,
                "@",
                "bitbucket.org/",
                _bitbucket_team,
                "/",
                repo_name_without_org,
                )
        elseif credentials == :with_redacted_auth
            result = string(
                "https://",
                _bitbucket_username,
                ":",
                "*****",
                "@",
                "bitbucket.org/",
                _bitbucket_team,
                "/",
                repo_name_without_org,
                )
        elseif credentials == :without_auth
            result =string(
                "https://",
                "bitbucket.org/",
                _bitbucket_team,
                "/",
                repo_name_without_org,
                )
        else
            error("$(credentials) is not a supported value for credentials")
        end
        return result
    end

    function _bitbucket_repo_exists((
            ;
            repo_name::String,
            )::Bool
        repo_name_without_org = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _bitbucket_team,
            )
        method = "GET"
        url = string(
            "https://",
            "$(_bitbucket_username)",
            ":",
            "$(_bitbucket_bot_app_password)",
            "@api.bitbucket.org",
            "/2.0",
            "/repositories",
            "/$(_bitbucket_team)",
            "/$(repo_name_without_org)",
            )
        result::Bool = try
            r = HTTP.request(
                method,
                url;
                basic_authorization = true,
                )
            true
        catch
            false
        end
        return result
    end

    function _create_repo(params::AbstractDict)::Nothing
        repo_name::String = strip(params[:repo_name])
        repo_name_with_org::String = _repo_name_with_org(
            ;
            repo = repo_name,
            org = _gitlab_group,
            )
        repo_name_without_org::String = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _gitlab_group,
            )
        repo_destination_url_without_auth = _get_destination_url(
            ;
            repo_name = repo_name_without_org,
            credentials = :without_auth,
            )
        if Utils._url_exists(repo_destination_url_without_auth)
            @info("According to HTTP GET request, the repo exists.")
        else
            if _bitbucket_repo_exists(; repo_name = repo_name_without_org)
                @info("According to the Bitbucket API, the repo exists.")
            else
                @info(
                    string("Creating new repo on Bitbucket"),
                    repo_destination_url_without_auth,
                    )
                method = "POST"
                url = string(
                    "https://",
                    "$(_bitbucket_username)",
                    ":",
                    "$(_bitbucket_bot_app_password)",
                    "@api.bitbucket.org",
                    "/2.0",
                    "/repositories",
                    "/$(_bitbucket_team)",
                    "/$(repo_name_without_org)",
                    )
                headers = Dict(
                    "content-type" => "application/json",
                    )
                params = Dict(
                    "scm" => "git",
                    "is_private" => false,
                    "name" => repo_name_without_org,
                    "slug" => repo_name_without_org,
                    "has_issues" => false,
                    "has_wiki" => false,
                    )
                body = JSON.json(params)
                r = HTTP.request(
                    method,
                    url,
                    headers,
                    body;
                    basic_authorization = true,
                    )
            end
        end
        return nothing
    end

    function _push_mirrored_repo(params::AbstractDict)::Nothing
        repo_name::String = params[:repo_name]
        repo_directory::String = params[:directory]
        git_path::String = params[:git]
        repo_name_without_org = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _bitbucket_team,
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
            string("Attempting to push repo to Bitbucket..."),
            mirrorpush_cmd_withredactedauth,
            pwd(),
            ENV["PATH"],
            )
        mirrorpush_was_success = try
            # Utils.command_ran_successfully!!(mirrorpush_cmd_withauth)
            success(mirrorpush_cmd_withauth)
        catch exception
            @warn("Ignoring exception: ", exception)
            false
        end
        if mirrorpush_was_success
            @info("Successfully pushed repo to Bitbucket.")
        else
            error("An error occured while attempting to push to Bitbucket.")
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
        by::String = strip(string("@", _bitbucket_username))

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
        repo_name::String = strip(params[:repo_name])
        new_repo_description = strip(params[:new_repo_description])
        _create_repo(
            Dict(
                :repo_name => repo_name,
                ),
            )
        repo_name_without_org::String = _repo_name_without_org(
            ;
            repo = repo_name,
            org = _bitbucket_team,
            )
        method = "PUT"
        url = string(
            "https://",
            "$(_bitbucket_username)",
            ":",
            "$(_bitbucket_bot_app_password)",
            "@api.bitbucket.org",
            "/2.0",
            "/repositories",
            "/$(_bitbucket_team)",
            "/$(repo_name_without_org)",
            )
        headers = Dict(
            "content-type" => "application/json",
            )
        params = Dict(
            "description" => strip(new_repo_description),
            )
        body = JSON.json(params)
        r = HTTP.request(
            method,
            url,
            headers,
            body;
            basic_authorization = true,
            )
        return nothing
    end

    function _bitbucket_provider(task::Symbol)::Function
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

    return _bitbucket_provider
end

end # End submodule MirrorUpdater.Hosts.BitbucketHost

##### End of file
