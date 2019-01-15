##### Beginning of file

Test.@test( isdir(MirrorUpdater.package_directory()) )

Test.@test( isdir(MirrorUpdater.package_directory("ci")) )

Test.@test( isdir(MirrorUpdater.package_directory("ci", "travis")) )

Test.@test( isdir(MirrorUpdater.package_directory(TestModuleA)) )

Test.@test( isdir(MirrorUpdater.package_directory(TestModuleB)) )

Test.@test(
    isdir( MirrorUpdater.package_directory(TestModuleB, "directory2",) )
    )

Test.@test(
    isdir(
        MirrorUpdater.package_directory(
            TestModuleB, "directory2", "directory3",
            )
        )
    )

Test.@test_throws(
    ErrorException,MirrorUpdater.package_directory(TestModuleC),
    )

##### End of file
