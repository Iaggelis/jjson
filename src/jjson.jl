module jjson

include("./lexer.jl")
include("./parser.jl")

using Mmap

function popnfirst!(a::Array{T,1}, n::Int64) where T
    for i in 1:n
        popfirst!(a)
    end
end

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

function parsejson(filename::String)
    tokens = lexer(filename)
    parsed_json = parser!(tokens)
    return parsed_json
end # parsejson

end # module
