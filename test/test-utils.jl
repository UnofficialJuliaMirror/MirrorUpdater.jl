##### Beginning of file

git = MirrorUpdater.Utils._get_git_binary_path()
@info(string("git: "), git,)

git_version_cmd = `$(git) --version`
@info(string("Attempting to run command: "), git_version_cmd,)
Test.@test(
    MirrorUpdater.Utils.command_ran_successfully!!(git_version_cmd)
    )

##### End of file
