##### Beginning of file

module Utils # Begin submodule MirrorUpdater.Utils

__precompile__(true)

import ..Types

import Conda
import Dates
import HTTP
import TimeZones

function default_repo_description(
        ;
        env::AbstractDict = ENV,
        from::Any = "",
        when::Any = Dates.now(TimeZones.localzone(),),
        time_zone::Dates.TimeZone = TimeZones.TimeZone("America/New_York"),
        by::Any = "",
        )::String

    _from::String = strip(string(from))
    from_string::String = ""
    if length(_from) == 0
        from_string = ""
    else
        from_string = strip(
            string(
                " from $(from_string)",
                )
            )
    end

    _when::String = ""
    date_time_string::String = ""
    if isa(when, TimeZones.ZonedDateTime)
        _when = strip(
            string(TimeZones.astimezone(when,time_zone,))
            )
    else
        _when = strip(
            string(when)
            )
    end
    if length(_when) == 0
        date_time_string = ""
    else
        date_time_string = strip(
            string(
                " on ",
                _when,
                )
            )
    end

    by_string::String = ""
    _by::String = strip(
        string(by)
        )
    if length(_by) == 0
        by_string = ""
    else
        by_string = strip(
            string(
                " by ",
                _by,
                )
            )
    end

    travis_string::String = ""
    if _is_travis_ci(env)
        TRAVIS_BUILD_NUMBER::String = strip(
            get(env, "TRAVIS_BUILD_NUMBER", "")
            )
        TRAVIS_JOB_NUMBER::String = strip(
            get(env, "TRAVIS_JOB_NUMBER", "")
            )
        TRAVIS_EVENT_TYPE::String = strip(
            get(env, "TRAVIS_EVENT_TYPE", "unknown-travis-event")
            )
        TRAVIS_BRANCH = strip(
            get(env, "TRAVIS_BRANCH", "unknown-branch")
            )
        TRAVIS_COMMIT = strip(
            get(env, "TRAVIS_COMMIT", "unknown-commit")
            )
        TRAVIS_PULL_REQUEST = strip(
            get(env,"TRAVIS_PULL_REQUEST","unknown-pull-request-number")
            )

        job_or_build_string::String = ""
        if length(TRAVIS_JOB_NUMBER) > 0
            job_or_build_string = strip(string("job $(TRAVIS_JOB_NUMBER)"))
        elseif length(TRAVIS_BUILD_NUMBER) > 0
            job_or_build_string = strip(string("build $(TRAVIS_BUILD_NUMBER)"))
        else
            job_or_build_string = ""
        end

        triggered_by_string::String = ""
        if lowercase(TRAVIS_EVENT_TYPE) == "push"
            triggered_by_string = strip(
                string(
                    ", triggered by the push of",
                    " commit \"$(TRAVIS_COMMIT)\"",
                    " to branch \"$(TRAVIS_BRANCH)\"",
                    )
                )
        elseif lowercase(TRAVIS_EVENT_TYPE) == "pull_request"
            triggered_by_string = strip(
                string(
                    ", triggered by ",
                    "pull request #$(TRAVIS_PULL_REQUEST)",
                    )
                )
        elseif lowercase(TRAVIS_EVENT_TYPE) == "cron"
            triggered_by_string = strip(
                string(
                    ", triggered by Travis",
                    " cron job on",
                    " branch \"$(TRAVIS_BRANCH)\"",
                    )
                )
        else
            triggered_by_string = strip(
                string(
                    ", triggered by Travis \"",
                    strip(TRAVIS_EVENT_TYPE),
                    "\" event on",
                    " branch \"$(TRAVIS_BRANCH)\"",
                    )
                )
        end
        travis_string = strip(
            string(
                " via Travis",
                job_or_build_string,
                triggered_by_string,
                )
            )
    else
        travis_string = ""
    end

    new_description::String = strip(
        string(
            "Last mirrored",
            from_string,
            date_time_string,
            travis_string,
            )
        )

    return new_description
end

function _url_exists(url::AbstractString)::Bool
    _url::String = strip(convert(String, url))
    result::Bool = try
        r = HTTP.request("GET", _url)
        @debug("HTTP GET request result: ", _url, r.status,)
        r.status == 200
    catch exception
        @debug(string("Ignoring exception"), exception,)
        false
    end
    if result
    else
        @debug(string("URL does not exist"), _url,)
    end
    return result
end

function command_ran_successfully!!(
        cmds::Base.AbstractCmd,
        args...;
        max_attempts::Integer = 10,
        max_seconds_per_attempt::Real = 540,
        seconds_to_wait_between_attempts::Real = 30,
        )::Bool
    result_bool::Bool = false
    for attempt = 1:max_attempts
        if result_bool
        else
            @debug(string("Attempt $(attempt)"))
            if attempt > 1
                timedwait(
                    () -> false,
                    float(seconds_to_wait_between_attempts),
                    )
            end
            p = run(cmds, args...; wait = false,)
            timedwait(
                () -> process_exited(p),
                float(max_seconds_per_attempt),
                )
            if process_running(p)
                result_bool = false
                try
                    kill(p, Base.SIGTERM)
                catch exception
                    @warn("Ignoring exception: ", exception)
                end
                try
                    kill(p, Base.SIGKILL)
                catch exception
                    @warn("Ignoring exception: ", exception)
                end
            else
                result_bool = try
                    success(p)
                catch exception
                    @warn("Ignoring exception: ", exception)
                    false
                end
            end
        end
    end
    result_string::String = result_bool ? "success" : "failure"
    @debug(string("Result: $(result_string)"))
    return result_bool
end

function _is_travis_ci(
        a::AbstractDict = ENV,
        )::Bool
    ci::String = lowercase(
        strip(get(a, "CI", "false"))
        )
    travis::String = lowercase(
        strip(get(a, "TRAVIS", "false"))
        )
    continuous_integration::String = lowercase(
        strip(get(a, "CONTINUOUS_INTEGRATION", "false"))
        )
    ci_is_true::Bool = ci == "true"
    travis_is_true::Bool = travis == "true"
    continuous_integration_is_true::Bool = continuous_integration == "true"
    answer::Bool = ci_is_true &&
        travis_is_true &&
        continuous_integration_is_true
    return answer
end

function _get_git_binary_path(
        environment::Union{AbstractString,Symbol} = :MirrorUpdater,
        )::String
    path_git_conda_specified_env::String = try
        joinpath(Conda.bin_dir(environment), "git",)
    catch exception
        @debug("ignoring exception: ", exception,)
        ""
    end
    success_git_conda_specified_env::Bool = false
    if length(path_git_conda_specified_env) > 0
        success_git_conda_specified_env = try
            success(`$(path_git_conda_specified_env) --version`)
        catch exception
            @debug("ignoring exception: ", exception,)
            false
        end
    else
        success_git_conda_specified_env = false
    end

    path_git_conda_root_env::String = try
        joinpath(Conda.bin_dir(Conda.ROOTENV), "git",)
    catch exception
        @debug("ignoring exception: ", exception,)
        ""
    end
    success_git_conda_root_env = false
    if length(path_git_conda_root_env) > 0
        success_git_conda_root_env = try
            success(`$(path_git_conda_root_env) --version`)
        catch exception
            @debug("ignoring exception: ", exception,)
            false
        end
    else
        success_git_conda_root_env = false
    end
    path_git_default::String = "git"
    success_git_default::Bool = try
        success(`$(path_git_default) --version`)
    catch
        false
    end
    @debug(
        "MirrorUpdater conda environment:",
        environment,
        success_git_conda_specified_env,
        path_git_conda_specified_env,
        )
    @debug(
        "Root conda environment:",
        success_git_conda_root_env,
        path_git_conda_root_env,
        )
    @debug(
        "Default git:",
        success_git_default,
        path_git_default,
        )
    if success_git_conda_specified_env
        git_path_to_use = path_git_conda_specified_env
    elseif success_git_conda_root_env
        git_path_to_use = path_git_conda_root_env
    elseif success_git_default
        git_path_to_use = path_git_default
    else
        error(
            string(
                "I could not find a usable Git."
                )
            )
    end
    result::String = strip(git_path_to_use)
    @debug(
        string(
            "Selected git: $(result)",
            ),
        )
    return result
end

end # End submodule MirrorUpdater.Utils

##### End of file
