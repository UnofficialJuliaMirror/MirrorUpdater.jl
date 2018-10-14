#!/bin/bash

##### Beginning of file

set -ev

export JULIA_FLAGS="--code-coverage=all --check-bounds=yes --color=yes"

echo "JULIA_FLAGS=$JULIA_FLAGS"

julia $JULIA_FLAGS -e 'import Pkg; Pkg.build("MirrorUpdater");'

julia $JULIA_FLAGS -e 'import MirrorUpdater;'

julia $JULIA_FLAGS -e 'import Pkg; Pkg.test("MirrorUpdater"; coverage=true);'

cat Project.toml

cat Manifest.toml

# julia $JULIA_FLAGS -e 'import Pkg; try Pkg.add("Coverage") catch end;'

# julia $JULIA_FLAGS -e '
#     import Coverage;
#     import MirrorUpdater;
#     cd(MirrorUpdater.package_directory());
#     Coverage.Codecov.submit(Coverage.Codecov.process_folder());
#     '

##### End of file
