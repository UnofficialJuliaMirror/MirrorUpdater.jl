##### Beginning of file

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
        from_string = string(
            " ",
            strip(string("from $(_from)",)),
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
        date_time_string = string(
            " ",
            strip(string("on ",_when,)),
            )
    end

    by_string::String = ""
    _by::String = strip(
        string(by)
        )
    if length(_by) == 0
        by_string = ""
    else
        by_string = string(
            " ",
            strip(string("by ",_by,)),
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
            job_or_build_string = string(
                " ",
                strip(string("job $(TRAVIS_JOB_NUMBER)")),
                )
        elseif length(TRAVIS_BUILD_NUMBER) > 0
            job_or_build_string = string(
                " ",
                strip(string("build $(TRAVIS_BUILD_NUMBER)")),
                )
        else
            job_or_build_string = ""
        end

        triggered_by_string::String = ""
        if lowercase(TRAVIS_EVENT_TYPE) == "push"
            triggered_by_string = string(
                " ",
                strip(
                    string(
                        ", triggered by the push of",
                        " commit \"$(TRAVIS_COMMIT)\"",
                        " to branch \"$(TRAVIS_BRANCH)\"",
                        )
                    ),
                )
        elseif lowercase(TRAVIS_EVENT_TYPE) == "pull_request"
            triggered_by_string = string(
                " ",
                strip(
                    string(
                        ", triggered by",
                        " pull request #$(TRAVIS_PULL_REQUEST)",
                        )
                    ),
                )
        elseif lowercase(TRAVIS_EVENT_TYPE) == "cron"
            triggered_by_string = string(
                " ",
                strip(
                    string(
                        ", triggered by Travis",
                        " cron job on",
                        " branch \"$(TRAVIS_BRANCH)\"",
                        )
                    ),
                )
        else
            triggered_by_string = string(
                " ",
                strip(
                    string(
                        ", triggered by Travis \"",
                        strip(TRAVIS_EVENT_TYPE),
                        "\" event on",
                        " branch \"$(TRAVIS_BRANCH)\"",
                        )
                    ),
                )
        end
        travis_string = string(
            " ",
            strip(
                string(
                    "via Travis",
                    job_or_build_string,
                    triggered_by_string,
                    )
                ),
            )
    else
        travis_string = ""
    end

    new_description::String = strip(
        string(
            "Last mirrored",
            from_string,
            date_time_string,
            by_string,
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

mutable struct _DummyOutputWrapperStruct{I, F, S, O}
    previous_time_seconds::I
    f::F
    interval_seconds::I
    dummy_output::S
    io::O
end

function _DummyOutputWrapperStruct(
        ;
        interval_seconds::I = 60,
        initial_offset_seconds::I = interval_seconds,
        f::F,
        dummy_output::S = "This is a dummy line of output",
        io::O = Base.stdout,
        )::_DummyOutputWrapperStruct{I, F, S, O} where
            I <: Integer where
            F <: Function where
            S <: AbstractString where
            O <: IO
    current_time_seconds::I = floor(I, time())
    initial_time_seconds::I = current_time_seconds + initial_offset_seconds
    wrapper_struct::_DummyOutputWrapperStruct{I, F, S} =
        _DummyOutputWrapperStruct(
            initial_time_seconds,
            f,
            interval_seconds,
            dummy_output,
            io,
            )
    return wrapper_struct
end

function (x::_DummyOutputWrapperStruct{I, F, S, O})() where
        I <: Integer where
        F <: Function where
        S <: AbstractString where
        O <: IO
    current_time_seconds::I = floor(I, time())
    previous_time_seconds::I = x.previous_time_seconds
    f::F = x.f
    interval_seconds::I = x.interval_seconds
    dummy_output::S = x.dummy_output
    io::O = x.io
    elapsed_seconds::Int = current_time_seconds - previous_time_seconds
    print_dummy_output::Bool = elapsed_seconds > interval_seconds
    if print_dummy_output
        println(io, dummy_output)
        x.previous_time_seconds = current_time_seconds
    end
    f_result = f()
    return f_result
end

function dummy_output_wrapper(
        ;
        f::F,
        interval_seconds::I = 60,
        initial_offset_seconds::I = interval_seconds,
        dummy_output::S = "This is a dummy line of output",
        io::O = Base.stdout,
        ) where
            I <: Integer where
            F <: Function where
            S <: AbstractString where
            O <: IO
    wrapper_struct::_DummyOutputWrapperStruct{I, F, S, O} =
        _DummyOutputWrapperStruct(
            ;
            f = f,
            interval_seconds = interval_seconds,
            initial_offset_seconds = initial_offset_seconds,
            dummy_output = dummy_output,
            )
    function my_wrapper_function()
        result = wrapper_struct()
        return result
    end
    return my_wrapper_function
end

function command_ran_successfully!!(
        cmd::Base.AbstractCmd;
        max_attempts::Integer = 10,
        max_seconds_per_attempt::Real = 540,
        seconds_to_wait_between_attempts::Real = 30,
        error_on_failure::Bool = true,
        last_resort_run::Bool = true,
        before::Function = () -> (),
        )::Bool
    success_bool::Bool = false

    my_false = dummy_output_wrapper(
        ;
        f = () -> false,
        interval_seconds = 60,
        initial_offset_seconds = 60,
        dummy_output = "Still waiting between attempts...",
        io = Base.stdout,
        )

    for attempt = 1:max_attempts
        if success_bool
        else
            @debug(string("Attempt $(attempt)"))
            if attempt > 1
                timedwait(
                    () -> my_false(),
                    float(seconds_to_wait_between_attempts);
                    pollint = float(1.0),
                    )
            end
            before()
            p = run(cmd; wait = false,)
            my_process_exited = dummy_output_wrapper(
                ;
                f = () -> process_exited(p),
                interval_seconds = 60,
                initial_offset_seconds = 60,
                dummy_output = "The process is still running...",
                io = Base.stdout,
                )
            timedwait(
                () -> my_process_exited(),
                float(max_seconds_per_attempt),
                pollint = float(1.0),
                )
            if process_running(p)
                success_bool = false
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
                success_bool = try
                    success(p)
                catch exception
                    @warn("Ignoring exception: ", exception)
                    false
                end
            end
        end
    end
    if !success_bool && last_resort_run
        @debug(string("Attempting the last resort run..."))
        try
            run(cmd)
            success_bool = true
        catch exception
            success_bool = false
            if error_on_failure
                delayederror(string(exception); exception = exception,)
            else
                @error(string(exception), exception = exception,)
            end
        end
    end
    if success_bool
        @debug(string("Command ran successfully."),)
    else
        if error_on_failure
            delayederror(string("Command did not run successfully."),)
        else
            @warn(string("Command did not run successfully."),)
        end
    end
    return success_bool
end

function retry_function_until_success(
        f::Function;
        max_attempts::Integer = 10,
        seconds_to_wait_between_attempts::Real = 30,
        use_delayed_error::Bool = true,
        )
    success_bool::Bool = false
    f_result = nothing

    my_false = dummy_output_wrapper(
        ;
        f = () -> false,
        interval_seconds = 60,
        initial_offset_seconds = 60,
        dummy_output = "Still waiting between attempts...",
        io = Base.stdout,
        )

    for attempt = 1:max_attempts
        if success_bool
        else
            @debug(string("Attempt $(attempt)"))
            if attempt > 1
                timedwait(
                    () -> my_false(),
                    float(seconds_to_wait_between_attempts);
                    pollint = float(1.0),
                    )
            end
            @debug(string("Running the provided function..."))
            success_bool = true
            f_result = try
                f()
            catch exception
                success_bool = false
                @warn("Ignoring exception: ", exception)
                nothing
            end
        end
    end

    if success_bool
        @debug(string("Function ran successfully."),)
        return f_result
    elseif use_delayed_error
        delayederror(string("Function did not run successfully."),)
    else
        error(string("Function did not run successfully."))
    end
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

##### End of file
