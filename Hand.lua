
hand = {
    tiles = {-1, -1, -1},  -- рука пустая
    zone = {},
    TIME_PER_ANIMATION_FRAME = 0.07,
    animation_timer = 0,
}


function hand.init()
    -- ищем руку на map, фиксируем тайлы руки
    for x = 0, 29 do
        for y = 0, 16 do
            if HAND[mget(x, y)] then
                table.insert(hand.zone, {x=x, y=y, value=mget(x, y)})
            end
        end
    end
end

-- анимация через mset
-- лень думать, поэтому вместо адекватных остатков использую конечный автомат
-- назовем такой автомат конченным, потому что на самом деле он делает код хуже
hand.animation = {
    [210] = 212,
    [212] = 214,
    [214] = 216,
    [216] = 210,

    [211] = 213,
    [213] = 215,
    [215] = 217,
    [217] = 211,

    [226] = 228,
    [228] = 230,
    [230] = 232,
    [232] = 226,

    [227] = 229,
    [229] = 231,
    [231] = 233,
    [233] = 227,
}
function hand.update_animation()

    if hand.animation_timer <= 0 then
        hand.animation_timer = hand.TIME_PER_ANIMATION_FRAME
        for i = 1, #hand.zone do
            hand.zone[i].value = hand.animation[ hand.zone[i].value ]
            mset( hand.zone[i].x, hand.zone[i].y, hand.zone[i].value )
        end
    end

    hand.animation_timer = Basic.tick_timer(hand.animation_timer)
end
