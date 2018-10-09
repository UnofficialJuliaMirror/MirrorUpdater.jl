##### Beginning of file

module CommandLine # Begin submodule MirrorUpdater.CommandLine

__precompile__(true)

import ArgParse
import Conda
import Dates
import HTTP
import Pkg
import TimeZones

import ..Types
import ..Utils
import ..Common
import ..Run

function run_mirror_updater_command_line!!(
        ;
        git_hosting_providers::AbstractVector = [],
        arguments::Vector{String},
        registry_list::Vector{Types.Registry},
        additional_repos::Vector{Types.SrcDestPair},
        do_not_push_to_these_destinations::Vector{String},
        do_not_try_url_list::Vector{String},
        try_but_allow_failures_url_list::Vector{String},
        time_zone::TimeZones.TimeZone =
            TimeZones.TimeZone("America/New_York"),
        )::Nothing
    @info(
        "Running MirrorUpdater.CommandLine.run_mirror_updater_command_line!!"
        )
    @info("parsing command line arguments...")
    parsed_arguments::Dict = _parse_arguments(
        arguments
        )
    @info("processing parsed command line arguments...")
    processed_arguments::Dict = _process_parsed_arguments(
        parsed_arguments
        )
    task::String = processed_arguments[:task]
    has_gist_description::Bool =  processed_arguments[:has_gist_description]
    gist_description::String = processed_arguments[:gist_description]
    is_dry_run::Bool = processed_arguments[:is_dry_run]
    Run.run_mirror_updater!!(
        ;
        git_hosting_providers = git_hosting_providers,
        task = task,
        gist_description = gist_description,
        is_dry_run = is_dry_run,
        registry_list = registry_list,
        additional_repos = additional_repos,
        time_zone = time_zone,
        do_not_push_to_these_destinations =
            do_not_push_to_these_destinations,
        do_not_try_url_list =
            do_not_try_url_list,
        try_but_allow_failures_url_list =
            try_but_allow_failures_url_list,
        )
    return nothing
end

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

function _process_parsed_arguments(parsed_arguments::Dict)::Dict{Symbol, Any}
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
    result::Dict{Symbol, Any} = Dict{Symbol, Any}()
    result[:task] = task
    result[:has_gist_description] = has_gist_description
    result[:gist_description] = gist_description
    result[:is_dry_run] = is_dry_run

    return result
end

end # End submodule MirrorUpdater.CommandLine

##### End of file
