struct DelayedError
    msg::S where S <: AbstractString
    dict::T where T <: AbstractDict
end

function process_delayed_error_list(list)::Nothing
    if isempty(list)
        @debug("There were no delayed errors.")
    else
        for x in list
            @error("Delayed error from earlier: $(x.msg)", x.dict...)
        end
        error("There were one or more delayed errors.")
    end
    return nothing
end

function process_delayed_error_list()::Nothing
    global delayed_error_list
    process_delayed_error_list(delayed_error_list)
    return nothing
end

function delayederror(msg::S; kwargs...)::Nothing where S <: AbstractString
    x = DelayedError(msg, Dict(kwargs...))
    global delayed_error_list
    push!(delayed_error_list, x,)
    @error("Delaying this error for later: $(x.msg)", x.dict...)
    return nothing
end

function delayederror(msg::Vararg{Any,N}; kwargs...)::Nothing where {N}
    delayederror(Main.Base.string(msg); kwargs...)
    return nothing
end

function delayedexit(n)::Nothing
    process_delayed_error_list()
    exit(n)
end

delayedexit() = delayedexit(0)
