##### Beginning of file

module GitLabHost # Begin submodule MirrorUpdater.Hosts.GitLabHost

__precompile__(true)

import ..Types
import ..Utils

import Dates
# import GitLab
import TimeZones

function new_github_session(
        ;
        gitlab_group::String,
        gitlab_token::String,
        )::Function

    error("GitLab is not yet supported.")

    function _gitlab_provider(task::Symbol)::Function
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

    return _gitlab_provider
end

end # End submodule MirrorUpdater.Hosts.GitLabHost

##### End of file
