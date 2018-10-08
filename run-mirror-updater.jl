##### Beginning of file

@info("Importing the MirrorUpdater module...")
pushfirst!(Base.LOAD_PATH, joinpath(@__DIR__, "src"))
import MirrorUpdater

@info("Reading config files...")
include(joinpath("config", "additional-repos.jl"))
include(joinpath("config", "do-not-push-to-these-destinations.jl"))
include(joinpath("config", "do-not-try-url-list.jl"))
include(joinpath("config", "git-hosting-providers.jl"))
include(joinpath("config", "gitlab.jl"))
include(joinpath("config", "github.jl"))
include(joinpath("config", "registries.jl"))
include(joinpath("config", "time_zone.jl"))
include(joinpath("config", "try-but-allow-failures-url-list.jl"))

@info("Running the main run_mirror_updater method...")
MirrorUpdater.GitHubMirrorUpdater.run_mirror_updater_command_line!!(
    ;
    arguments = ARGS,
    github_organization = GITHUB_ORGANIZATION,
    github_token = GITHUB_TOKEN,
    registry_list = REGISTRY_LIST,
    additional_repos = ADDITIONAL_REPOS,
    do_not_push_to_these_destinations = DO_NOT_PUSH_TO_THESE_DESTINATIONS,
    do_not_try_url_list = DO_NOT_TRY_URL_LIST,
    try_but_allow_failures_url_list = TRY_BUT_ALLOW_FAILURES_URL_LIST,
    time_zone = TIME_ZONE,
    )

##### End of file
