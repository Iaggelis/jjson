# Parser
function parse_array(tokens::Vector{Any})
    jsonArray = Vector{Any}()

    t = tokens[1]
    if t == JSON_RIGHTBRACKET
        return jsonArray, tokens[2:end]
    end # if

    while true
        rest, tokens = parser(tokens)
        push!(jsonArray, rest)
        t = tokens[1]

        if t == JSON_RIGHTBRACKET
            return jsonArray, tokens[2:end]
        elseif t != JSON_COMMA
            error("No comma found in array")
        else
            tokens = tokens[2:end]
        end # if
    end # while

end # parse_array

function parse_object(tokens::Vector{Any})
    jsonObject = Dict{String, Any}()

    t = tokens[1]
    if t == JSON_RIGHTBRACE
        return jsonObject, tokens[2:end]
    end # if

    while true
        jsonKey = tokens[1]
        if typeof(jsonKey) == String
            tokens = tokens[2:end]
        else
            error("Expected key string, but got ", jsonKey)
        end # if

        if tokens[1] != JSON_COLON
            error("Expected colon but got ", tokens[1])
        end # if

        jsonValue, tokens = parser(tokens[2:end])

        jsonObject[jsonKey] = jsonValue

        t = tokens[1]

        if t == JSON_RIGHTBRACE
            return jsonObject, tokens[2:end]
        elseif t != JSON_COMMA
            error("Expected comma in object")
        end # if

        try
            tokens = tokens[2:end]
        catch
        end
    end # while
end # parse_object

function parser(tokens::Vector{Any})
    t = tokens[1]

    if t == JSON_LEFTBRACKET
        return parse_array(tokens[2:end])
    elseif t == JSON_LEFTBRACE
        return parse_object(tokens[2:end])
    else
        return t, tokens[2:end]
    end # if

end # parser
