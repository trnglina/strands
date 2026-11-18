local styles = { em = "\27[3m", b = "\27[1m" }

local function render(text)
    local out = {}
    for _, node in ipairs(text) do
        if node.inline == "text" then
            out[#out + 1] = node.value
        else
            out[#out + 1] = (styles[node.inline] or "") .. render(node.text) .. "\27[0m"
        end
    end
    return table.concat(out)
end

return render
