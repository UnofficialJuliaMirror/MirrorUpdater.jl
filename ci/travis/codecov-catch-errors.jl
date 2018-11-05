import Pkg

try
    Pkg.add("Coverage")
catch e1
    @warn(
        string("Ignoring exception e1:"),
        e1,
        )
end

import Coverage

import MirrorUpdater

cd(MirrorUpdater.package_directory())

try
    Coverage.Codecov.submit(Coverage.Codecov.process_folder())
catch e2
    @warn(
        string("Ignoring exception e2:"),
        e2,
        )
end
