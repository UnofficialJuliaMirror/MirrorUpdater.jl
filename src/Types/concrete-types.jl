##### Beginning of file

struct Package
    name::String
    uuid::String
    source_url::String
    function Package(
            name::String,
            uuid::String,
            source_url::String,
            )::Package
        correct_name = _name_with_jl(name)
        correct_uuid = strip(uuid)
        correct_source_url = strip(source_url)
        result::Package = new(
            correct_name,
            correct_uuid,
            correct_source_url,
            )
        return result
    end
end



struct Registry
    owner::String
    name::String
    uuid::String
    url::String
    function Registry(
            owner::String,
            name::String,
            uuid::String,
            url::String,
            )::Registry
        correct_owner = strip(owner)
        correct_name = _name_without_jl(name)
        correct_uuid = strip(uuid)
        correct_url = strip(url)
        result::Registry = new(
            correct_owner,
            correct_name,
            correct_uuid,
            correct_url,
            )
        return result
    end
end



struct SrcDestPair
    source_url::String
    destination_repo_name::String
    function SrcDestPair(
            source_url::String,
            destination_repo_name::String,
            )::SrcDestPair
        correct_source_url = strip(source_url)
        correct_destination_repo_name = strip(destination_repo_name)
        result::SrcDestPair = new(
            correct_source_url,
            correct_destination_repo_name,
            )
        return result
    end
end

struct TwoSidedInterval <: AbstractInterval
    left::String
    right::String
    function TwoSidedInterval(
            left::String,
            right::String,
            )::TwoSidedInterval
        correct_left = strip(left)
        correct_right = strip(right)
        result::TwoSidedInterval = new(
            correct_left,
            correct_right,
            )
        return result
    end
end

struct OneSidedInterval <: AbstractInterval
    left::String
    function OneSidedInterval(
            left::String,
            )::OneSidedInterval
        correct_left = strip(left)
        result::OneSidedInterval = new(
            correct_left,
            )
        return result
    end
end

##### End of file
