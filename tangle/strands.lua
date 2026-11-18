-- tangle/strands.lua
--
-- Written in 2026 by trnglina <teng@trnglina.org>
--
-- To the extent possible under law, the author(s) have dedicated all
-- copyright and related and neighboring rights to this software to the public
-- domain worldwide. This software is distributed without any warranty.
--
-- You should have received a copy of the CC0 Public Domain Dedication along
-- with this software.
--
-- If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

local Strands = {}
Strands.__index = Strands

function Strands.new()
    local self = setmetatable({}, Strands)
    self.table = setmetatable({}, { __mode = "k" })
    return self
end

function Strands:register(fn)
    self.table[fn] = true
    return fn
end

function Strands:from_value(item)
    if self.table[item] == true then
        return item
    end
    if type(item) == "function" then
        return self:register(function(next, ...)
            return self:from_value(item(...))(next, ...)
        end)
    end
    return self:register(function(next, ...)
        return item, next
    end)
end

return Strands
