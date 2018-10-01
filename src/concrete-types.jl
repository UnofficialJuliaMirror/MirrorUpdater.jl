##### Beginning of file

function _name_with_jl(x::AbstractString)::String
    name_without_jl::String = _name_without_jl(x)
    name_with_jl::String = string(name_without_jl, ".jl")
    return name_with_jl
end

function _name_without_jl(x::AbstractString)::String
    temp::String = strip(convert(String, x))
    if endswith(lowercase(temp), ".jl")
        result = strip(temp[1:end-3])
    else
        result = temp
    end
    return result
end

function _name_with_git(x::AbstractString)::String
    name_without_git::String = _name_without_git(x)
    name_with_git::String = string(name_without_git, ".git")
    return name_with_git
end

function _name_without_git(x::AbstractString)::String
    temp::String = strip(convert(String, x))
    if endswith(lowercase(temp), ".git")
        result = strip(temp[1:end-4])
    else
        result = temp
    end
    return result
end

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

function _is_interval(x::String)::Bool
    result::Bool = _is_two_sided_interval(x) || _is_one_sided_interval(x)
    return result
end

function _get_two_sided_interval_regex()::Regex
    two_sided_interval_regex::Regex = r"\[(\w*?)\,(\w\w*?)\)"
    return two_sided_interval_regex
end

function _get_one_sided_interval_regex()::Regex
    one_sided_interval_regex::Regex = r"\[(\w*?)\,\)"
    return one_sided_interval_regex
end

function _is_two_sided_interval(x::String)::Bool
    result::Bool = occursin(_get_two_sided_interval_regex(), x)
    return result
end

function _is_one_sided_interval(x::String)::Bool
    result::Bool = occursin(_get_one_sided_interval_regex(), x)
    return result
end

function _construct_interval(x::String)::AbstractInterval
    if _is_two_sided_interval(x)
        twosided_regexmatch::RegexMatch = match(
            _get_two_sided_interval_regex(),
            x,
            )
        twosided_left::String = strip(
            convert(String, twosided_regexmatch[1])
            )
        twosided_right::String = strip(
            convert(String, twosided_regexmatch[2])
            )
        result = TwoSidedInterval(twosided_left, twosided_right)
    elseif _is_one_sided_interval(x)
        onesided_regexmatch::RegexMatch = match(
            _get_one_sided_interval_regex(),
            x,
            )
        one_sidedleft::String = strip(convert(String, onesided_regexmatch[1]))
        result = OneSidedInterval(one_sidedleft)
    else
        error("argument is not a valid interval")
    end
    return result
end

##### End of file
