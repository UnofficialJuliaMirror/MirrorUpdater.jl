##### Beginning of file

function Package(
        ;
        name::AbstractString,
        uuid::AbstractString,
        source_url::AbstractString,
        )::Package
    result::Package = Package(
        convert(String,name),
        convert(String,uuid),
        convert(String,source_url),
        )
    return result
end

function Registry(
        ;
        owner::AbstractString,
        name::AbstractString,
        uuid::AbstractString,
        url::AbstractString,
        )::Registry
    result::Registry = Registry(
        convert(String,owner),
        convert(String,name),
        convert(String,uuid),
        convert(String,url),
        )
    return result
end

function SrcDestPair(
    ;
    source_url::AbstractString,
    destination_repo_name::String,
    )::SrcDestPair
    result::SrcDestPair = SrcDestPair(
        convert(String, source_url),
        convert(String, destination_repo_name),
        )
    return result
end

##### End of file
