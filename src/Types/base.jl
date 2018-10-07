##### Beginning of file

function Base.isless(
        x::SrcDestPair,
        y::SrcDestPair,
        )::Bool
    x_destination_repo_name::String = strip(x.destination_repo_name)
    y_destination_repo_name::String = strip(y.destination_repo_name)
    result::Bool = Base.isless(
        x_destination_repo_name,
        y_destination_repo_name,
        )
    return result
end

##### End of file
