##### Beginning of file

module CommandLine # Begin submodule MirrorUpdater.CommandLine

__precompile__(true)

function _parse_arguments(arguments::Vector{String})::Dict
    s = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table s begin
        "--task"
            help = "which task to run"
            arg_type = String
            default = ""
        "--gist-description"
            help = "description for the temporary gist"
            arg_type = String
            default = ""
        "--dry-run"
            help = "do everything except actually pushing the repos"
            action = :store_true
    end
    result::Dict = ArgParse.parse_args(arguments, s)
    return result
end

function _process_parsed_arguments(parsed_arguments::Dict)::Tuple
    task_argument::String = strip(
        convert(String, parsed_arguments["task"])
        )
    if length(task_argument) > 0
        task = task_argument
    else
        task = "all"
    end

    gist_description::String = strip(
        convert(String, parsed_arguments["gist-description"])
        )
    if length(gist_description) > 0
        has_gist_description = true
    else
        has_gist_description = false
    end

    is_dry_run::Bool = parsed_arguments["dry-run"]
    return task, has_gist_description, gist_description, is_dry_run
end

end # End submodule MirrorUpdater.CommandLine

##### End of file
