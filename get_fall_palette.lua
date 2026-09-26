
function parse_color(hex)
    local r = tonumber(string.sub(hex, 1, 2), 16)
    local g = tonumber(string.sub(hex, 3, 4), 16)
    local b = tonumber(string.sub(hex, 5, 6), 16)
    return {r, g, b}
end

function get_fall_palette()
    local res = table.copy(GREEN_PALETTE)
    -- res[5] = parse_color('99b09b')
    -- res[11] = parse_color('f2e3a7')
    res[12] = res[14]
    return res
end

function get_dark_fall_palette()
    -- TODO!!!
    local res = table.copy(DARK_GREEN_PALETTE)
    res[12] = parse_color('b5a76d')
    return res
end