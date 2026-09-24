
function make_palette_grey(original_palette)
    local res = {}
    for key, color in pairs(original_palette) do
        local r = color[1]
        local g = color[2]
        local b = color[3]

        -- local y = 0.299 * r + 0.587 * g + 0.114 * b
        local y = 0.22 * r + 0.52 * g + 0.1 * b
        -- local y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        res[key] = {y,y,y}
    end
    return res
end
