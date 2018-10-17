##### Beginning of file

@info("Importing the MirrorUpdater module...")

pushfirst!(Base.LOAD_PATH, joinpath(@__DIR__, "src"))
import MirrorUpdater

import TimeZones

@info("Reading config files...")

include(joinpath("config","preferences","enabled-providers.jl",))
include(joinpath("config","preferences","gitlab.jl",))
include(joinpath("config","preferences","github.jl",))
include(joinpath("config","preferences","time-zone.jl",))

include(joinpath("config","repositories","additional-repos.jl",))
include(joinpath("config","repositories",
    "do-not-push-to-these-destinations.jl",))
include(joinpath("config","repositories",
    "do-not-try-url-list.jl",))
include(joinpath("config","repositories","registries.jl",))
include(joinpath("config","repositories",
    "try-but-allow-failures-url-list.jl",))

git_hosting_providers = Any[]

if GITHUB_ENABLED
    const github_provider =
        MirrorUpdater.Hosts.GitHubHost.new_github_session(
            ;
            github_organization = GITHUB_ORGANIZATION,
            github_personal_access_token = GITHUB_PERSONAL_ACCESS_TOKEN,
            )
    push!(git_hosting_providers, github_provider)
end

MirrorUpdater.CommandLine.run_mirror_updater_command_line!!(
    ;
    arguments = ARGS,
    git_hosting_providers = git_hosting_providers,
    registry_list = REGISTRY_LIST,
    additional_repos = ADDITIONAL_REPOS,
    do_not_try_url_list = DO_NOT_TRY_URL_LIST,
    do_not_push_to_these_destinations = DO_NOT_PUSH_TO_THESE_DESTINATIONS,
    try_but_allow_failures_url_list = TRY_BUT_ALLOW_FAILURES_URL_LIST,
    time_zone = TIME_ZONE,
    )

##### End of file
