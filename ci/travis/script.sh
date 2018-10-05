#!/bin/bash

##### Beginning of file

set -ev

export GIST_DESCRIPTION="$TRAVIS_BRANCH-$TRAVIS_BUILD_DIR-$TRAVIS_BUILD_ID-$TRAVIS_BUILD_NUMBER-$TRAVIS_COMMIT-$TRAVIS_EVENT_TYPE-$TRAVIS_PULL_REQUEST-$TRAVIS_PULL_REQUEST_BRANCH-$TRAVIS_PULL_REQUEST_SHA-$TRAVIS_PULL_REQUEST_SLUG-$TRAVIS_REPO_SLUG-$TRAVIS_TAG"

export TASK="$1"

if [[ "$TRAVIS_BRANCH" == "master" ]]
then
    if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
    then
        export DRY_RUN=""
    else
        export DRY_RUN="--dry-run"
    fi
else
    export DRY_RUN="--dry-run"
fi

echo "GIST_DESCRIPTION=$GIST_DESCRIPTION"
echo "TASK=$TASK"
echo "TRAVIS_BRANCH=$TRAVIS_BRANCH"
echo "TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST"
echo "DRY_RUN=$DRY_RUN"

# Remove the following line once the bug in GitHub.jl has been fixed and a new release has been tagged
julia --project -e 'import Pkg; p = Pkg.PackageSpec(name="GitHub", url="https://github.com/DilumAluthge/GitHub.jl", rev="da/fix-create-repo-bug"); Pkg.add(p);'

julia --project -e 'import Pkg; Pkg.resolve();'

julia --project deps/build.jl

julia --project run-github-mirror-updater.jl --gist-description "$GIST_DESCRIPTION" --task "$TASK" $DRY_RUN

cat Project.toml

cat Manifest.toml

##### End of file
