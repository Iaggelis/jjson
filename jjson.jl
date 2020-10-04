module jjson



function readfile_as_string(filename::String)
    lines = readlines(filename, keep=true) |> join
    return lines
end # readfile_as_string


const JSON_COMMA        = ','
const JSON_COLON        = ':'
const JSON_LEFTBRACKET  = '['
const JSON_RIGHTBRACKET = ']'
const JSON_LEFTBRACE    = '{'
const JSON_RIGHTBRACE   = '}'
const JSON_QUOTE        = '"'
const JSON_QUOTE      = '"'
const JSON_WHITESPACE = [' ', '\t', '\b', '\n', '\r']
const JSON_SYNTAX     = [JSON_COMMA, JSON_COLON, JSON_LEFTBRACKET,
                         JSON_RIGHTBRACKET, JSON_LEFTBRACE, JSON_RIGHTBRACE]

function lex_string(lines::Union{Char,String})

    jsonString = ""

    if lines[1] == JSON_QUOTE
        lines = lines[2:end]
    else
        return nothing, lines
    end # if


    for c in lines
        if c == JSON_QUOTE
            return jsonString, lines[length(jsonString)+2:end]
        else
            jsonString *= c
        end # if
    end # for


    error("No end of string found")

end # lex_string

function lex_number(lines::Union{Char,String})
    jsonNum = ""
    numbers = [convert(Char, string(i)[1]) for i in 0:9]
    push!(numbers, '-', 'e', '.')

    for c in lines
        if c in numbers
            jsonNum *= c
        else
            break
        end # if
    end # for

    rest = lines[length(jsonNum)+1:end]

    if length(jsonNum) == 0
        return nothing, rest
    end # if

    if '.' in jsonNum
        return parse(Float64, jsonNum), rest
    end # if

    return parse(Int64, jsonNum), rest

end # lex_number

function lex_bool(lines::Union{Char,String})

    if length(lines) >= 4
        if lines[:4] == "true"
            return true, lines[5:end]
        elseif lines[:4] == "null"
            return nothing, lines[5:end]
        end
    elseif length(lines) >= 5 && lines[1:5] == "false"
        return false, lines[6:end]
    end # if

    return nothing, lines
end # lex_bool

# function lexer(lines::Union{Char,String})
function lexer(filename::String)
    lines::String = join(readlines(filename, keep=true))
    tokens = Vector{Any}()

    while length(lines) > 0
        jsonString, lines = lex_string(String(lines))
        if jsonString !== nothing
            push!(tokens, jsonString)
            continue
        end # if

        jsonNum, lines = lex_number(String(lines))
        if jsonNum !== nothing
            push!(tokens, jsonNum)
            continue
        end # if

        jsonBool, lines = lex_bool(String(lines))
        if jsonBool !== nothing
            push!(tokens, jsonBool)
            continue
        end # if

        c = lines[1]

        if c in JSON_WHITESPACE
            lines = lstrip(lines)
        elseif c in JSON_SYNTAX
            push!(tokens, c)
            lines = lines[2:end]
        end # if
    end # while


    return tokens
end # lexer


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
            error("Expected colon")
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

end # module
