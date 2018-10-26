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
