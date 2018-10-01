##### Beginning of file

function command_ran_successfully(
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

##### End of file
