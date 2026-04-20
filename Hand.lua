
hand = {
    values = {-1, -1, -1},  -- рука пустая
    zone = {},
    TIME_PER_ANIMATION_FRAME = 0.07,
    animation_timer = 0,
    slots = {}
}

function hand.size()
    -- возвращает количество карт в руке
    local counter = 0
    for _, v in ipairs(hand.values) do
        if v ~= -1 then
            counter = counter + 1
        end
    end
    return counter
end


function hand.init()
    -- ищем руку на map, фиксируем тайлы руки
    for x = 0, 29 do
        for y = 0, 16 do
            if HAND[mget(x, y)] then
                table.insert(hand.zone, {x=x, y=y, value=mget(x, y)})
            end
            if mget(x, y) == 216 then
                table.insert(hand.slots, {x=x*8, y=y*8})
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
            if hand.full() then
                -- alarm
                mset( hand.zone[i].x, hand.zone[i].y, hand.zone[i].value - 32)
            else
                mset( hand.zone[i].x, hand.zone[i].y, hand.zone[i].value )
            end
        end
    end

    hand.animation_timer = Basic.tick_timer(hand.animation_timer)
end


function hand.is_tile_should_go_to_hand(tile)
    -- считаем хитбокс на два пикселя меньше
    local x1 = (tile.x + Tile.HITBOX.x1+1) / 8
    local y1 = (tile.y + Tile.HITBOX.y1+1) / 8
    local x2 = (tile.x + Tile.HITBOX.x2-1) / 8
    local y2 = (tile.y + Tile.HITBOX.y2-1) / 8
    return HAND[mget(x1, y1)] or
        HAND[mget(x1, y2)] or
        HAND[mget(x2, y1)] or
        HAND[mget(x2, y2)] 
end

function hand.add(tile)
    -- находим ближайший слот
    local nearest_slot_i = 0
    for i, slot in ipairs(hand.slots) do
        local nearest_slot = hand.slots[nearest_slot_i]
        if hand.values[i] == -1 and  -- слот не занят
            (nearest_slot_i == 0 or
            (slot.x - tile.x)^2 + (slot.y - tile.y)^2 < 
            (nearest_slot.x - tile.x)^2 + (nearest_slot.y - tile.y)^2) then
            -- trace(nearest_slot_i..' -> '..i)
            nearest_slot_i = i
        end
    end
    -- trace(nearest_slot_i)
    -- nearest tile i не может быть равен 0
    return nearest_slot_i
end

function hand.full()
    for _, value in ipairs(hand.values) do
        if value == -1 then
            return false
        end
    end
    return true
end

function hand.remove(slot_i)
    hand.values[slot_i] = -1
end

function hand.insert_into_slot(tile)
    local slot = hand.slots[tile.hand_slot_i]
    hand.values[tile.hand_slot_i] = tile.value
    -- tile.x = slot.x
    -- tile.y = slot.y
end

function hand.is_there_a_triplet()
    if not hand.full() then
        return false
    end
    return hand.values[1] == hand.values[2] and hand.values[2] == hand.values[3]
end

function hand.cancel_alarm()
    for i = 1, #hand.zone do
        mset( hand.zone[i].x, hand.zone[i].y, hand.zone[i].value )
    end
end
