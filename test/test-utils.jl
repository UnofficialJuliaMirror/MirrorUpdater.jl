##### Beginning of file

Test.@testset "git tests" begin

    git = MirrorUpdater.Utils._get_git_binary_path()
    @info(string("git: "), git,)

    git_version_cmd = `$(git) --version`
    @info(string("Attempting to run command: "), git_version_cmd,)
    Test.@test(
            MirrorUpdater.Utils.command_ran_successfully!!(
                    git_version_cmd
                    )
            )

    Test.@test(
            MirrorUpdater.Utils.command_ran_successfully!!(
                    `$(git) --version`
                    )
            )

    Test.@test_throws(
            ErrorException,
            MirrorUpdater.Utils.command_ran_successfully!!(
                    `$(git) --versionBLAHBLAHBLAH`;
                    max_attempts = 5,
                    seconds_to_wait_between_attempts = 5,
                    error_on_failure = true,
                    last_resort_run = true,
                    ),
            )

    Test.@test_throws(
            ErrorException,
            MirrorUpdater.Utils.command_ran_successfully!!(
                    `$(git) --versionBLAHBLAHBLAH`;
                    max_attempts = 5,
                    seconds_to_wait_between_attempts = 5,
                    error_on_failure = true,
                    last_resort_run = false,
                    ),
            )

    Test.@test_throws(
            ErrorException,
            MirrorUpdater.Utils.command_ran_successfully!!(
                    `$(git) --versionBLAHBLAHBLAH`;
                    max_attempts = 5,
                    seconds_to_wait_between_attempts = 5,
                    error_on_failure = false,
                    last_resort_run = true,
                    ),
            )

    Test.@test(
            !(
                    MirrorUpdater.Utils.command_ran_successfully!!(
                            `$(git) --versionBLAHBLAHBLAH`;
                            max_attempts = 5,
                            seconds_to_wait_between_attempts = 5,
                            error_on_failure = false,
                            last_resort_run = false,
                            )
                    )
            )

    function f_1()
            return "Hello There"
    end

    Test.@test(
            "Hello There" ==
                    MirrorUpdater.Utils.retry_function_until_success(
                            () -> f_1()
                            )
            )

    f_2_counter = Ref{Int}()
    f_2_counter[] = 0
    function f_2(counter)
            counter[] += 1
            @debug(
                    string(
                            "Incremented counter from ",
                            "$(counter[] - 1) to $(counter[])",
                            )
                    )
            if counter[] < 7
                    error("f2_counter < 7")
            else
                    return "General Kenobi"
            end
    end

    Test.@test(
            "General Kenobi" ==
                    MirrorUpdater.Utils.retry_function_until_success(
                            () -> f_2(f_2_counter);
                            max_attempts = 10,
                            seconds_to_wait_between_attempts = 5,
                            )
            )

    function f_3()
            error("f_3() will always fail")
    end

    Test.@test_throws(
            ErrorException,
            MirrorUpdater.Utils.retry_function_until_success(
        ()->f_3();
        max_attempts = 5,
        seconds_to_wait_between_attempts = 5,
            ),
            )

    previous_directory::String = pwd()
    temp_directory_1::String = joinpath(mktempdir(), "TEMPGITREPOLOCAL")
    mkpath(temp_directory_1)
    temp_directory_2::String = joinpath(mktempdir(), "TEMPGITREPOREMOTE")
    mkpath(temp_directory_2)
    cd(temp_directory_2)
    run(`$(git) init --bare`)
    cd(temp_directory_1)
    run(`$(git) init`)
    MirrorUpdater.Utils.git_add_all!()
    MirrorUpdater.Utils.git_commit!(
        ;
        message="test commit 1",
        allow_empty=true,
        committer_name="test name",
        committer_email="test email",
        )
    run(`git branch branch1`)
    run(`git branch branch2`)
    run(`git branch branch3`)
    run(`git checkout master`)
    Test.@test(
        typeof(MirrorUpdater.Utils.git_version()) <: VersionNumber
        )
    Test.@test(
        typeof(MirrorUpdater.Utils.get_all_branches_local()) <:
            Vector{String}
        )
    Test.@test(
        typeof(MirrorUpdater.Utils.get_all_branches_local_and_remote()) <:
            Vector{String}
        )
    Test.@test(
        typeof(MirrorUpdater.Utils.get_current_branch()) <: String )
    Test.@test(
        MirrorUpdater.Utils.branch_exists("branch1") )
    Test.@test(
        !MirrorUpdater.Utils.branch_exists("non-existent-branch") )
    Test.@test(
        !MirrorUpdater.Utils.branch_exists("non-existent-but-create-me") )
    Test.@test(
        typeof(MirrorUpdater.Utils.checkout_branch!("branch1")) <: Nothing )
    Test.@test_throws(
        ErrorException,
        MirrorUpdater.Utils.checkout_branch!("non-existent-branch"),
        )
    Test.@test_warn(
        "",
        MirrorUpdater.Utils.checkout_branch!(
            "non-existent-branch";
            error_on_failure=false,
            ),
        )
    Test.@test(
        typeof(
            MirrorUpdater.Utils.checkout_branch!(
                "non-existent-but-create-me";
                create=true,
                )
            ) <: Nothing
        )
    MirrorUpdater.Utils.git_add_all!()
    MirrorUpdater.Utils.git_commit!(
        ;
        message="test commit 2",
        allow_empty=true,
        committer_name="test name",
        committer_email="test email",
        )
    run(`git checkout master`)
    Test.@test(
        MirrorUpdater.Utils.branch_exists("branch1")
        )
    Test.@test(
        !MirrorUpdater.Utils.branch_exists("non-existent-branch")
        )
    Test.@test(
        MirrorUpdater.Utils.branch_exists("non-existent-but-create-me")
        )
    run(`$(git) remote add origin $(temp_directory_2)`)
    Test.@test(
        typeof(MirrorUpdater.Utils.git_push_upstream_all!()) <: Nothing
        )
    run(`git checkout master`)
    include_patterns::Vector{Regex} = Regex[
        r"^bRANCh1$"i,
        r"^bRanCh3$"i,
        ]
    exclude_patterns::Vector{Regex} = Regex[
        r"^brANcH3$"i,
        ]
    branches_to_snapshot::Vector{String} =
        MirrorUpdater.Utils.make_list_of_branches_to_snapshot(
            ;
            default_branch = "maSTeR",
            include = include_patterns,
            exclude = exclude_patterns,
            )
    Test.@test( length(branches_to_snapshot) == 2 )
    Test.@test( length(unique(branches_to_snapshot)) == 2 )
    Test.@test(
        length(branches_to_snapshot) == length(unique(branches_to_snapshot))
        )
    Test.@test( branches_to_snapshot[1] == "branch1" )
    Test.@test( branches_to_snapshot[2] == "master" )
    cd(previous_directory)
    MirrorUpdater.Utils.delete_everything_except_dot_git!(temp_directory_1)
    MirrorUpdater.Utils.delete_only_dot_git!(temp_directory_2)
    rm(temp_directory_1; recursive=true, force=true)
    rm(temp_directory_2; recursive=true, force=true)

end # end testset "git tests"

##### End of file
