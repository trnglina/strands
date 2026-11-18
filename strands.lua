local strands = {}

-- ========================================================================== --
-- Core API
-- ========================================================================== --

local function empty(state, next)
    return next(state)
end

local function done(_state)
    return { kind = "done" }
end

local function chain(left_strand, right_strand)
    return function(state_a, next)
        return left_strand(state_a, function(state_b)
            return right_strand(state_b, next)
        end)
    end
end

-- Constructs a strand from other strands.
function strands.ply(body)
    local head = empty
    for i = #body, 1, -1 do
        head = chain(body[i], head)
    end
    return head
end

-- Constructs a strand that _shows_ some content.
function strands.show(get_content)
    return function(state, next)
        return {
            kind = "content",
            content = get_content(state),
            next = next,
        }
    end
end

-- Constructs a strand that posts a question and _asks_ for a response.
function strands.ask(get_question)
    local function step(state, next, rejection)
        local question_block, answer = get_question(state)

        return {
            kind = "question",
            question = question_block,
            rejection = rejection,
            answer = function(state_b, response)
                local response_block, reason = answer(response, state_b)
                if not response_block then
                    return step(state_b, next, { response = response, reason = reason })
                end
                return response_block(state_b, next)
            end,
        }
    end

    return function(state, next)
        return step(state, next, nil)
    end
end

-- Constructs a strand that cuts at the current point, and jumps to the target
-- strand.
function strands.jump(target)
    return function(state, _next)
        return target(state, done)
    end
end

-- Constructs a strand that _lazily resolves_ to an inner strand based on the
-- current state.
function strands.lazy(get_strand)
    return function(state, continue)
        local strand = get_strand(state)
        return strand(state, continue)
    end
end

-- Conditionally include the given strand when the predicate holds.
function strands.when(predicate, strand)
    return strands.lazy(function(state)
        if predicate(state) then
            return strand
        end

        return empty
    end)
end

-- Start running the given strand with the given initial state.
function strands.start(strand, state)
    return strand(state, done)
end

return strands
