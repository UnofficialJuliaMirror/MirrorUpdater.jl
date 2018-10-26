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
            "@api.bitbucket.org/2.0",
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
