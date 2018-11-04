#!/bin/bash

##### Beginning of file

set -ev

export COMPILED_MODULES="$1"
echo "COMPILED_MODULES=$COMPILED_MODULES"

export JULIA_FLAGS="--check-bounds=yes --code-coverage=all --color=yes --compiled-modules=$COMPILED_MODULES --inline=no"
echo "JULIA_FLAGS=$JULIA_FLAGS"

julia $JULIA_FLAGS -e 'import Pkg; Pkg.build("MirrorUpdater");'
julia $JULIA_FLAGS -e 'import MirrorUpdater;'
julia $JULIA_FLAGS -e 'import Pkg; Pkg.test("MirrorUpdater"; coverage=true);'

cat Project.toml
cat Manifest.toml

julia $JULIA_FLAGS -e 'import Pkg; try Pkg.add("Coverage") catch end;'
julia $JULIA_FLAGS ci/travis/codecov-catch-errors.jl

##### End of file
