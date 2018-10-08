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

##### End of file
