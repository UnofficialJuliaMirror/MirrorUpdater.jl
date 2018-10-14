##### Beginning of file

import InteractiveUtils
import MirrorUpdater
import Test

git = MirrorUpdater.Utils._get_git_binary_path()
git_version_cmd = `$(git) --version`
Test.@test(
    MirrorUpdater.Utils.command_ran_successfully!!(git_version_cmd)
    )

##### End of file
