
hand = {
    tiles = {},  -- рука пустая
    -- обе границы включены
    x1 = 150,
    y1 = 100,
    x2 = 150+50,
    y2 = 100+30,
}

function hand.draw_hitbox()
    rect(hand.x1, hand.y1, hand.x2-hand.x1, hand.y2-hand.y1, 1)
end

function hand.draw()
    local x = (hand.x1 + hand.x2) / 2
    local y = (hand.y1 + hand.y2) / 2
    spr(209, x, y, 0, 1,0,0,2,2)
end
