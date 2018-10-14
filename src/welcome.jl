##### Beginning of file

function _print_welcome_message()::Nothing
    mirrorupdater_version::VersionNumber = version()
    mirrorupdater_pkgdir::String = package_directory()
    @info(string("This is MirrorUpdater, version ",mirrorupdater_version,),)
    @info(string("For help, please visit https://github.com/UnofficialJuliaMirror/MirrorUpdater.jl",),)
    @debug(string("MirrorUpdater package directory: ",mirrorupdater_pkgdir,),)
    return nothing
end

##### End of file
