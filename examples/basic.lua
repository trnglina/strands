local strands = require('strands')
local render = require('examples._render')

local em = strands.dsl.em
local b = strands.dsl.b

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function get_reporter()
    local caller = debug.getinfo(3, "Sl")
    local where = caller.short_src .. ":" .. caller.currentline

    return function(message)
        error(where .. ": " .. message, 0)
    end
end

--------------------------------------------------------------------------------
-- Custom DSL
--------------------------------------------------------------------------------

local function p(...)
    local children = { ... }
    local fail = get_reporter()

    return strands.show(function(state)
        local text = strands.dsl._resolve_inlines(children, state)
        if text == nil then
            fail("invalid text content: " .. type(children))
        end

        return { block = "p", text = text }
    end)
end

local function choices(children)
    local fail = get_reporter()

    return strands.ask(function(state)
        local choices = {}
        local options = {}

        for i, option in ipairs(strands.dsl._resolve(children, state)) do
            local id = option.id
            if id == nil then
                fail("choice option " .. i .. " has no id")
            end

            if options[id] ~= nil then
                fail("duplicate choice id: " .. tostring(id))
            end

            local label = strands.dsl._resolve_inlines(option.label, state)
            if label == nil then
                fail("invalid label content: " .. type(option.label))
            end

            choices[#choices + 1] = { block = "choice", id = id, label = label }
            options[id] = option
        end

        local block = { block = "choice_list", choices = choices }

        local function answer(id)
            local option = options[id]
            if option == nil then
                return nil, { code = "unknown_choice", id = id }
            end
            return strands.ply(option)
        end

        return block, answer
    end)
end

--------------------------------------------------------------------------------
-- Strands
--------------------------------------------------------------------------------

local main = strands.ply {
    p("It's a ", em "wonderful", " world out there."),
}

--------------------------------------------------------------------------------
-- Harness
--------------------------------------------------------------------------------

local state = {}
local step = strands.start(main, state)

while step.kind ~= "done" do
    if step.kind == "show" then
        print(render(step.content.text))
        local _ = io.read()
        step = step.next(state)
    elseif step.kind == "ask" then
        local cs = step.question.choices
        for i, choice in ipairs(cs) do
            print(i .. ") " .. render(choice.label))
        end

        io.write("> ")
        local line = io.read("l")
        if line == nil then
            return
        end

        local choice = cs[tonumber(line)]
        step = step.answer(state, choice and choice.id)
    end
end
