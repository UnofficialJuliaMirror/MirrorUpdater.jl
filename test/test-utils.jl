##### Beginning of file

import MirrorUpdater
import Test

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
        max_attempts = 10,
        seconds_to_wait_between_attempts = 5,
        ),
    )

Test.@test(
    !(
        MirrorUpdater.Utils.command_ran_successfully!!(
            `$(git) --versionBLAHBLAHBLAH`;
            max_attempts = 10,
            seconds_to_wait_between_attempts = 5,
            error_on_failure = false,
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
    MirrorUpdater.Utils.retry_function_until_success(()->f_3()),
    )

##### End of file
