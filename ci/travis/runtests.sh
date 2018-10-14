#!/bin/bash

##### Beginning of file

set -ev

julia --check-bounds=yes --color=yes -e '
    import Pkg;
    Pkg.build("MirrorUpdater");
    '

julia --check-bounds=yes --color=yes -e '
    import MirrorUpdater;
    '

julia --check-bounds=yes --color=yes -e '
    import Pkg;
    Pkg.test("MirrorUpdater"; coverage=true);
    '

cat Project.toml

cat Manifest.toml

##### End of file
