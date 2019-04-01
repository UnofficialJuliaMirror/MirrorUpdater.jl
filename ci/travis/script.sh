#!/bin/bash

##### Beginning of file

set -ev

export JULIA_FLAGS="--check-bounds=yes --code-coverage=all --color=yes --compiled-modules=no --inline=no --project"
echo "JULIA_FLAGS=$JULIA_FLAGS"

export TASK="$1"
export GIST_DESCRIPTION="MirrorUpdater-Travis-$TRAVIS_EVENT_TYPE-$TRAVIS_BRANCH-$TRAVIS_BUILD_DIR-$TRAVIS_BUILD_ID-$TRAVIS_BUILD_NUMBER-$TRAVIS_COMMIT-$TRAVIS_EVENT_TYPE-$TRAVIS_PULL_REQUEST-$TRAVIS_PULL_REQUEST_BRANCH-$TRAVIS_PULL_REQUEST_SHA-$TRAVIS_PULL_REQUEST_SLUG-$TRAVIS_REPO_SLUG-$TRAVIS_TAG"

export FORCE_DRY_RUN_ARGUMENT="$2"
echo "FORCE_DRY_RUN_ARGUMENT=$FORCE_DRY_RUN_ARGUMENT"

if [[ "$FORCE_DRY_RUN_ARGUMENT" == "FORCE_DRY_RUN" ]]
then
    export DRY_RUN="--dry-run"
else
    if [[ "$TRAVIS_BRANCH" == "master" ]]
    then
        if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
        then
            export DRY_RUN=""
        else
            export DRY_RUN="--dry-run"
        fi
    else
        if [[ "$TRAVIS_BRANCH" == "staging" ]]
        then
            if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
            then
                export DRY_RUN=""
            else
                export DRY_RUN="--dry-run"
            fi
        else
            if [[ "$TRAVIS_BRANCH" == "trying" ]]
            then
                if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
                then
                    export DRY_RUN="--dry-run"
                else
                    export DRY_RUN="--dry-run"
                fi
            else
                export DRY_RUN="--dry-run"
            fi
        fi
    fi
fi

echo "DRY_RUN=$DRY_RUN"
echo "GIST_DESCRIPTION=$GIST_DESCRIPTION"
echo "TASK=$TASK"
echo "TRAVIS_BRANCH=$TRAVIS_BRANCH"
echo "TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST"

julia $JULIA_FLAGS -e 'import Pkg; Pkg.resolve();'
julia $JULIA_FLAGS -e 'import Pkg; Pkg.build("MirrorUpdater");'
julia $JULIA_FLAGS run-mirror-updater.jl --delete-gists-older-than-minutes 10080 --gist-description "$GIST_DESCRIPTION" --task "$TASK" $DRY_RUN

cat Project.toml
cat Manifest.toml

julia $JULIA_FLAGS -e 'import Pkg; try Pkg.add("Coverage") catch end;'
julia $JULIA_FLAGS ci/travis/codecov-catch-errors.jl

##### End of file
