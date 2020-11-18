# Parser
function parse_array!(tokens::Vector{Any})
    jsonArray = Vector{Any}()

    if tokens[1] == JSON_RIGHTBRACKET
        popfirst!(tokens)
        return jsonArray
    end # if

    while true
        rest = parser!(tokens)
        push!(jsonArray, rest)

        if tokens[1] == JSON_RIGHTBRACKET
            popfirst!(tokens)
            return jsonArray
        elseif tokens[1] != JSON_COMMA
            error("No comma found in array")
        else
            popfirst!(tokens)
        end # if
    end # while

end # parse_array

function parse_object!(tokens::Vector{Any})
    jsonObject = Dict{String, Any}()

    if tokens[1] == JSON_RIGHTBRACE
        popfirst!(tokens)
        return jsonObject
    end # if

    while true
        jsonKey = tokens[1]
        if typeof(jsonKey) == String
            popfirst!(tokens)
        else
            error("Expected key string, but got ", jsonKey)
        end # if

        if tokens[1] != JSON_COLON
            error("Expected colon but got ", tokens[1])
        end # if

        popfirst!(tokens)

        jsonObject[jsonKey] = parser!(tokens)


        if tokens[1] == JSON_RIGHTBRACE
            popfirst!(tokens)
            return jsonObject
        elseif tokens[1] != JSON_COMMA
            error("Expected comma in object but got", tokens[1])
        end # if

        try
            popfirst!(tokens)
        catch
        end
    end # while
end # parse_object

function parser!(tokens::Vector{Any})
    t = popfirst!(tokens)
    if t == JSON_LEFTBRACKET
        return parse_array!(tokens)
    elseif t == JSON_LEFTBRACE
        return parse_object!(tokens)
    else
        return t
    end # if

end # parser
