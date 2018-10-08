##### Beginning of file

module GitHubHost # Begin submodule MirrorUpdater.Hosts.GitHubHost

__precompile__(true)

function _generate_new_repo_description(
        x::Types.SrcDestPair,
        a::AbstractDict = ENV;
        github_organization::String,
        github_user::String,
        when::TimeZones.ZonedDateTime = Dates.now(TimeZones.localzone()),
        time_zone::Dates.TimeZone = Dates.TimeZone("America/New_York"),
        )::String
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
        repo_name::String,
        new_repo_description::String,
        auth::GitHub.Authorization,
        github_organization::String,
        github_user::String,
        )::Nothing
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
        _repo_name_without_organization(
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

function _create_dest_repo_if_it_doesnt_exist!!(
        x::Types.SrcDestPair,
        github_organization::String;
        auth::GitHub.Authorization,
        )::Nothing
    repo_fullname = _get_repo_fullname(x, github_organization,)
    _create_dest_repo_if_it_doesnt_exist!!(
        repo_fullname,
        github_organization;
        auth = auth,
        )
    return nothing
end

function _create_dest_repo_if_it_doesnt_exist!!(
        repo_fullname::String,
        github_organization::String;
        auth::GitHub.Authorization,
        )::Nothing
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

end # End submodule MirrorUpdater.Hosts.GitHubHost

##### End of file
