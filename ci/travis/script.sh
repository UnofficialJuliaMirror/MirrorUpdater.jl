#!/bin/bash

##### Beginning of file

set -ev

export GIST_DESCRIPTION="$TRAVIS_BRANCH-$TRAVIS_BUILD_DIR-$TRAVIS_BUILD_ID-$TRAVIS_BUILD_NUMBER-$TRAVIS_COMMIT-$TRAVIS_EVENT_TYPE-$TRAVIS_PULL_REQUEST-$TRAVIS_PULL_REQUEST_BRANCH-$TRAVIS_PULL_REQUEST_SHA-$TRAVIS_PULL_REQUEST_SLUG-$TRAVIS_REPO_SLUG-$TRAVIS_TAG"
echo "GIST_DESCRIPTION: "
echo $GIST_DESCRIPTION

export TASK="$1"
echo "TASK: "
echo $TASK

echo "TRAVIS_BRANCH: "
echo $TRAVIS_BRANCH

julia --project -e 'import Pkg; p = Pkg.PackageSpec(name="GitHub", url="https://github.com/DilumAluthge/GitHub.jl", rev="da/fix-create-repo-bug"); Pkg.add(p);'

julia --project -e 'import Pkg; Pkg.resolve();'

julia --project deps/build.jl

if [[ "$TRAVIS_BRANCH" == "master" ]]
then
    julia --project run-github-mirror-updater.jl --gist-description "$GIST_DESCRIPTION" --task "$TASK"
else
    julia --project run-github-mirror-updater.jl --dry-run --gist-description "$GIST_DESCRIPTION" --task "$TASK"
fi

cat Project.toml

cat Manifest.toml

##### End of file
