##### Beginning of file

Test.@test( Base.VERSION >= VersionNumber("1.0") )

Test.@test( MirrorUpdater.version() > VersionNumber(0) )

Test.@test(
    MirrorUpdater.version() ==
        MirrorUpdater.version(MirrorUpdater)
    )

Test.@test(
    MirrorUpdater.version() ==
        MirrorUpdater.version(first(methods(MirrorUpdater.eval)))
    )

Test.@test(
    MirrorUpdater.version() ==
        MirrorUpdater.version(MirrorUpdater.eval)
    )

Test.@test(
    MirrorUpdater.version() ==
        MirrorUpdater.version(MirrorUpdater.eval, (Any,))
    )

Test.@test( MirrorUpdater.version(TestModuleA) == VersionNumber("1.2.3") )

Test.@test( MirrorUpdater.version(TestModuleB) == VersionNumber("4.5.6") )

Test.@test_throws(
    ErrorException,
    MirrorUpdater._TomlFile(joinpath(mktempdir(),"1","2","3","4")),
    )

##### End of file
