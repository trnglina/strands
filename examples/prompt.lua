local strands = require('strands')

--------------------------------------------------------------------------------
-- DSL
--------------------------------------------------------------------------------

local function p(...)
    local children = { ... }
    return function(state)
        local piece = {}
        for i, child in ipairs(children) do
            if type(child) == "function" then
                piece[i] = child(state)
            else
                piece[i] = child
            end
        end
        return piece
    end
end

local function get(key)
    return function(state)
        return state[key]
    end
end

local function set(key)
    return function(value)
        return { kind = "set", key = key, value = value:upper() }
    end
end

local function prompt(resolve)
    return { kind = "prompt", resolve = resolve }
end

--------------------------------------------------------------------------------
-- Strands
--------------------------------------------------------------------------------

local main = strands {
    p("Hello there! Welcome to the world of POKEMON! My name is OAK! People ",
        "call me the POKEMON PROF! This world is inhabited by creatures ",
        "called POKEMON! For some people, POKEMON are pets. Others use them ",
        "for fights. Myself...I study POKEMON as a profession. First, what ",
        "is your name?"),

    prompt(set("player")),

    p("Right! So your name is ", get("player"), "! This is my grandson. He's ",
        "been your rival since you were a baby. ...Erm, what is his name ",
        "again? "),

    prompt(set("rival")),

    p("That's right! I remember now! His name is ", get("rival"), "! ",
        get("player"), "! Your very own POKEMON legend is about to unfold! A ",
        "world of dreams and adventures with POKEMON awaits! Let's go! "),
}

--------------------------------------------------------------------------------
-- Harness
--------------------------------------------------------------------------------

local state = {}
local piece, next = strands.run(main, state)

while next do
    if piece.kind == "prompt" then
        local response
        repeat
            io.write("> ")
            local answer = io.read()
            if answer == nil then
                return
            end
            answer = answer:match("^%s*(.-)%s*$")
            if answer ~= "" then
                response = piece.resolve(answer)
            end
        until response ~= nil
        io.write('\n')

        piece = response
    else
        if piece.kind == "set" then
            state[piece.key] = piece.value
        else
            for _, text in ipairs(piece) do
                io.write(text)
            end
            io.write('\n')
        end

        piece, next = next(state)
    end
end
