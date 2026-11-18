-- tangle.lua
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

local Strands = require("tangle.strands")

local Tangle = {}
Tangle.__index = Tangle

function Tangle.new()
    local self = setmetatable({}, Tangle)

    self.strands = Strands.new()

    self.EMPTY = self.strands:register(function(next, ...)
        return next(...)
    end)

    self.DONE = self.strands:register(function(...)
        return nil, nil
    end)

    return self
end

function Tangle:ply(items)
    if #items == 0 then
        return self.EMPTY
    end
    local head = self.strands:from_value(items[#items])
    for i = #items - 1, 1, -1 do
        local rest = head
        local strand = self.strands:from_value(items[i])
        head = self.strands:register(function(next, ...)
            return strand(function(...)
                return rest(next, ...)
            end, ...)
        end)
    end
    return head
end

function Tangle:to(target)
    local strand = self.strands:from_value(target)
    return self.strands:register(function(_next, ...)
        return strand(self.DONE, ...)
    end)
end

function Tangle:run(item, ...)
    return self.strands:from_value(item)(self.DONE, ...)
end

return Tangle
