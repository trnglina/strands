local brands = setmetatable({}, { __mode = "k" })

local function brand(fn)
    brands[fn] = true
    return fn
end

local empty = brand(function(next, ...)
    return next(...)
end)

local done = brand(function(...)
    return nil, nil
end)

local function strand(item)
    if brands[item] == true then
        return item
    end
    if type(item) == "function" then
        return brand(function(next, ...)
            return strand(item(...))(next, ...)
        end)
    end
    return brand(function(next, ...)
        return item, next
    end)
end

local function chain(items)
    if #items == 0 then
        return empty
    end
    local head = strand(items[#items])
    for i = #items - 1, 1, -1 do
        local rest = head
        head = brand(function(next, ...)
            return strand(items[i])(function(...)
                return rest(next, ...)
            end, ...)
        end)
    end
    return head
end

local function to(target)
    return brand(function(_next, ...)
        return strand(target)(done, ...)
    end)
end

local function run(item, ...)
    return strand(item)(done, ...)
end

return setmetatable(
    { to = to, run = run },
    { __call = function(_, items) return chain(items) end }
)
