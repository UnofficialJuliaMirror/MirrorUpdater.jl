##### Beginning of file

module GitHubHost # Begin submodule MirrorUpdater.Hosts.GitHubHost

__precompile__(true)

import ..Types
import ..Utils

import Dates
import GitHub
import TimeZones

function _create_dest_repo_if_it_doesnt_exist!!(
        ;
        args::Dict,
        host_params::Dict,
        )::Nothing
    x = args[:x]

    # (
    #     x::Types.SrcDestPair,
    #     github_organization::String;
    #     auth::GitHub.Authorization,
    #     )::Nothing
    repo_fullname = _get_repo_fullname(x, github_organization,)
    _create_dest_repo_if_it_doesnt_exist!!(
        repo_fullname,
        github_organization;
        auth = auth,
        )
    return nothing
end

function _create_dest_repo_if_it_doesnt_exist!!(
        ;
        args::Dict,
        host_params::Dict,
        )::Nothing
    # (
    #     repo_fullname::String,
    #     github_organization::String;
    #     auth::GitHub.Authorization,
    #     )::Nothing
    dest_url_withoutauth = _get_destination_url(
        repo_fullname;
        github_organization = github_organization,
        )
    repo_name_with_organization = _repo_name_with_organization(
        ;
        repo = repo_fullname,
        org = github_organization,
        )
    repo_name_without_organization = (
        ;
        repo = repo_fullname,
        org = github_organization,
        )
    if _url_exists(dest_url_withoutauth)
    else
        if _github_repo_exists(repo_fullname; auth=auth)
        else
            @info("Creating new repo: $(dest_url_withoutauth)")
            owner = GitHub.owner(
                github_organization,
                true;
                auth = auth,
                )
            params = Dict{String, Any}(
                "has_issues" => "false",
                "has_wiki" => "false",
                )
            repo = GitHub.create_repo(
                owner,
                repo_name_without_organization,
                params;
                auth = auth,
                )
        end
    end
    return nothing
end

function _github_push_to_repo!!(
        ;
        args::Dict,
        host_params::Dict,
        )::Nothing
    return nothing
end

function _generate_new_repo_description(
        ;
        args::Dict,
        host_params::Dict,
        )::String
    # (
    #     x::Types.SrcDestPair,
    #     a::AbstractDict = ENV;
    #     github_organization::String,
    #     github_user::String,
    #     when::TimeZones.ZonedDateTime = Dates.now(TimeZones.localzone()),
    #     time_zone::Dates.TimeZone = Dates.TimeZone("America/New_York"),
    #     )::String
    source_url::String = x.source_url
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
    date_time_string = string(
        TimeZones.astimezone(
            when,
            time_zone,
            )
        )
    result::String = string(
        "Mirrored from $(source_url) on ",
        date_time_string,
        " by @$(github_user)",
        via_travis,
        )
    return result
end

function _edit_repo_description_github!!(
        ;
        args::Dict,
        host_params::Dict,
        )::Nothing
    # (
    #     ;
    #     repo_name::String,
    #     new_repo_description::String,
    #     auth::GitHub.Authorization,
    #     github_organization::String,
    #     github_user::String,
    #     )::Nothing
    full_repo_name::String = _repo_name_with_organization(
        ;
        repo = repo_name,
        org = github_organization,
        )
    _create_dest_repo_if_it_doesnt_exist!!(
        full_repo_name,
        github_organization;
        auth = auth,
        )
    repo = GitHub.repo(full_repo_name; auth = auth,)
    result = GitHub.gh_patch_json(
        GitHub.DEFAULT_API,
        "/repos/$(GitHub.name(repo.owner))/$(GitHub.name(repo.name))";
        auth = auth,
        params = Dict(
            "name" => GitHub.name(repo.name),
            "description" => new_repo_description,
            )
        )
    return nothing
end

function _github_delete_gists!!(
        ;
        args::Dict,
        host_params::Dict,
        )::Nothing
    github_user = host_params[:github_user]
    my_github_auth = host_params[:my_github_auth]
    gist_description::String = args[:gist_description]
    list_of_gist_ids_to_delete::Vector{String} = String[]
    @info("loading all my GitHub gists")
    my_gists_stage3::Vector{GitHub.Gist} = GitHub.gists(
        github_user;
        auth = my_github_auth,)[1]
    for gist in my_gists_stage3
        if gist.description == gist_description
            push!(list_of_gist_ids_to_delete, gist.id)
        end
    end
    for gist_id_to_delete in list_of_gist_ids_to_delete
        GitHub.delete_gist(gist_id_to_delete;auth = my_github_auth,)
        @info(string("deleted GitHub gist id $(gist_id_to_delete)"))
    end
    return nothing
end

function _github_create_gist!!(
        ;
        args::Dict,
        host_params::Dict,
        )::Nothing
    my_github_auth = host_params[:my_github_auth]
    gist_description::String = args[:gist_description]
    gist_content_stage1::String = args[:gist_content_stage1]
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
    return nothing
end

function _github_retrieve_gist(
        ;
        args::Dict,
        host_params::Dict,
        )::String
    my_github_auth = host_params[:my_github_auth]
    github_user = host_params[:github_user]
    gist_description = args[:gist_description]
    @info("loading all of my GitHub gists")
    my_gists_stage2::Vector{GitHub.Gist} = GitHub.gists(
        github_user;
        auth = my_github_auth,
        )[1]
    correct_gist_id::String = ""
    for gist in my_gists_stage2
        if gist.description == gist_description
            correct_gist_id = gist.id
        end
    end
    result::String = ""
    if length(correct_gist_id) > 0
        @info("downloading the correct GitHub gist")
        correct_gist::GitHub.Gist = GitHub.gist(
            correct_gist_id;auth = my_github_auth,)
        correct_gist_content_stage2::String = correct_gist.files[
            "list.txt"]["content"]
        result = correct_gist_content_stage2
    else
        result = ""
    end
    return result
end

function _get_github_username(
        auth::GitHub.Authorization,
        )
    user_information::AbstractDict = GitHub.gh_get_json(
        GitHub.DEFAULT_API,
        "/user";
        auth = auth,
        )
    username::String = user_information["name"]
    username_stripped::String = strip(username)
    return username_stripped
end

function _get_destination_url(
        destination_repo_name::String;
        github_organization::String,
        github_user::String = "",
        github_token::String = "",
        ):String
    destination_repo_name_without_organization::String =
        Utils._repo_name_without_organization(
            ;
            repo = destination_repo_name,
            org = github_organization,
            )
    has_credentials = (length(github_user) > 0) &&
        (length(github_token) > 0)
    if has_credentials
        result = string(
            "https://",
            github_user,
            ":",
            github_token,
            "@github.com/",
            github_organization,
            "/",
            destination_repo_name_without_organization,
            )
    else
        result = string(
            "https://github.com/",
            github_organization,
            "/",
            destination_repo_name_without_organization,
            )
    end
    return result
end

function _get_destination_url(
        x::Types.SrcDestPair;
        github_organization::String,
        github_user::String = "",
        github_token::String = "",
        ):String
    destination_repo_name::String = strip(x.destination_repo_name)
    result::String = _get_destination_url(
        destination_repo_name;
        github_organization = github_organization,
        github_user = github_user,
        github_token = github_token,
        )
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

end # End submodule MirrorUpdater.Hosts.GitHubHost

##### End of file
