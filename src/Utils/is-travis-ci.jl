##### Beginning of file

function _is_travis_ci(
        a::AbstractDict = ENV,
        )::Bool
    ci::String = lowercase(
        strip(get(a, "CI", "false"))
        )
    travis::String = lowercase(
        strip(get(a, "TRAVIS", "false"))
        )
    continuous_integration::String = lowercase(
        strip(get(a, "CONTINUOUS_INTEGRATION", "false"))
        )
    ci_is_true::Bool = ci == "true"
    travis_is_true::Bool = travis == "true"
    continuous_integration_is_true::Bool = continuous_integration == "true"
    answer::Bool = ci && travis && continuous_integration
    return answer
end

##### End of file
