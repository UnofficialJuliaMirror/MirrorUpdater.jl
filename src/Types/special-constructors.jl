##### Beginning of file

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
