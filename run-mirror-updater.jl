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

git_hosting_providers::Vector{Any} = Any[]

if GITHUB_ENABLED
    const github_provider = MirrorUpdater.Hosts.GitHubHost.new_github_session(
        ;
        github_organization = GITHUB_ORGANIZATION,
        github_token = GITHUB_TOKEN,
        )
    push!(git_hosting_providers, github_provider)
end

if MirrorUpdater.Utils._is_travis_ci()
    error(
        string(
            "I still need to test this code locally ",
            "with the --dry-run flag ",
            "and with no gist description.",
            ),
        )
    error(
        string(
            "I still need to test this code locally ",
            "with the --dry-run flag ",
            "and with --gist-description equal to \"dilum-local-test\"",
            "",
            "",
            ),
        )
    error(
        string(
            "I still need to test this code locally ",
            "with no gist description.",
            ),
        )
    error(
        string(
            "I still need to test this code locally ",
            "with --gist-description equal to \"dilum-local-test\"",
            ),
        )
end

MirrorUpdater.CommandLine.run_mirror_updater_command_line!!(
    ;
    arguments = ARGS,
    git_hosting_providers = git_hosting_providers,
    registry_list = REGISTRY_LIST,
    additional_repos = ADDITIONAL_REPOS,
    do_not_push_to_these_destinations = DO_NOT_PUSH_TO_THESE_DESTINATIONS,
    do_not_try_url_list = DO_NOT_TRY_URL_LIST,
    try_but_allow_failures_url_list = TRY_BUT_ALLOW_FAILURES_URL_LIST,
    time_zone = TIME_ZONE,
    )

##### End of file
