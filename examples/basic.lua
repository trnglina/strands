local strands = require('strands')

--------------------------------------------------------------------------------
-- DSL
--------------------------------------------------------------------------------

local br = { kind = "br" }

local function ln(line_n)
    return { "Line ", tostring(line_n), ": " }
end

--------------------------------------------------------------------------------
-- Strands
--------------------------------------------------------------------------------

local main = strands {
    ln, { [["Yes, of course, if it's fine tomorrow," said Mrs. Ramsay. ]],
    [["But you'll have to be up with the lark," she added.]] }, br,

    ln, { "To her son these words conveyed an extraordinary joy, as if it ",
    "were settled, the expedition were bound to take place, and the ",
    "wonder to which he had looked forward, for years and years it ",
    "seemed, was, after a night's darkness and a day's sail, within ",
    "touch." }, br,

    ln, { [["But," said his father, stopping in front of the drawing-room ]],
    [[window, "it won't be fine."]] }
}

--------------------------------------------------------------------------------
-- Harness
--------------------------------------------------------------------------------

local line_n = 1
local piece, next = strands.run(main, line_n)

while next do
    for _, text in ipairs(piece) do
        io.write(text)
    end

    if piece.kind == "br" then
        if io.read() == nil then
            return
        end
        io.write('\n')
        line_n = line_n + 1
    end

    piece, next = next(line_n)
end
