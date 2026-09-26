function get_green_to_blue_palette()
    local res = table.copy(GREEN_PALETTE)
    res[5] = res[8]
    res[11] = res[3]
    res[12] = res[15]
    return res
end

function get_dark_green_to_blue_palette()
    local res = {
        [5] = {99, 128, 145},
        [11] = {126, 159, 153},
        [12] = {126, 159, 153},
    }
    return res
end