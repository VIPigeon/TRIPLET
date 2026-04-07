CENTER = {x=14*8, y=8*8}

game = {
    tiles = {
        Tile:new(CENTER.x, CENTER.y, 256),
        Tile:new(CENTER.x, CENTER.y, 256),
        Tile:new(CENTER.x, CENTER.y, 256),
        Tile:new(CENTER.x, CENTER.y, 258),
        Tile:new(CENTER.x, CENTER.y, 258),
        Tile:new(CENTER.x, CENTER.y, 258),
        Tile:new(CENTER.x, CENTER.y, 260),
        Tile:new(CENTER.x, CENTER.y, 260),
        Tile:new(CENTER.x, CENTER.y, 260),
        Tile:new(CENTER.x, CENTER.y, 262),
        Tile:new(CENTER.x, CENTER.y, 262),
        Tile:new(CENTER.x, CENTER.y, 262),
        Tile:new(CENTER.x, CENTER.y, 264),
        Tile:new(CENTER.x, CENTER.y, 264),
        Tile:new(CENTER.x, CENTER.y, 264),
        Tile:new(CENTER.x, CENTER.y, 266),
        Tile:new(CENTER.x, CENTER.y, 266),
        Tile:new(CENTER.x, CENTER.y, 266),
        Tile:new(CENTER.x, CENTER.y, 268),
        Tile:new(CENTER.x, CENTER.y, 268),
        Tile:new(CENTER.x, CENTER.y, 268),
        Tile:new(CENTER.x, CENTER.y, 270),
        Tile:new(CENTER.x, CENTER.y, 270),
        Tile:new(CENTER.x, CENTER.y, 270),
        -- Tile:new(CENTER.x, CENTER.y, 288),
        -- Tile:new(CENTER.x, CENTER.y, 288),
        -- Tile:new(CENTER.x, CENTER.y, 288),
        -- Tile:new(CENTER.x, CENTER.y, 290),
        -- Tile:new(CENTER.x, CENTER.y, 290),
        -- Tile:new(CENTER.x, CENTER.y, 290),
        -- Tile:new(CENTER.x, CENTER.y, 292),
        -- Tile:new(CENTER.x, CENTER.y, 292),
        -- Tile:new(CENTER.x, CENTER.y, 292),
        -- Tile:new(CENTER.x, CENTER.y, 294),
        -- Tile:new(CENTER.x, CENTER.y, 294),
        -- Tile:new(CENTER.x, CENTER.y, 294),
        -- Tile:new(CENTER.x, CENTER.y, 296),
        -- Tile:new(CENTER.x, CENTER.y, 296),
        -- Tile:new(CENTER.x, CENTER.y, 296),
        -- Tile:new(CENTER.x, CENTER.y, 298),
        -- Tile:new(CENTER.x, CENTER.y, 298),
        -- Tile:new(CENTER.x, CENTER.y, 298),
        -- Tile:new(CENTER.x, CENTER.y, 300),
        -- Tile:new(CENTER.x, CENTER.y, 300),
        -- Tile:new(CENTER.x, CENTER.y, 300),
        -- Tile:new(CENTER.x, CENTER.y, 302),
        -- Tile:new(CENTER.x, CENTER.y, 302),
        -- Tile:new(CENTER.x, CENTER.y, 302),
        -- Tile:new(CENTER.x, CENTER.y, 320),
        -- Tile:new(CENTER.x, CENTER.y, 320),
        -- Tile:new(CENTER.x, CENTER.y, 320),
        -- Tile:new(CENTER.x, CENTER.y, 322),
        -- Tile:new(CENTER.x, CENTER.y, 322),
        -- Tile:new(CENTER.x, CENTER.y, 322),
        -- Tile:new(CENTER.x, CENTER.y, 324),
        -- Tile:new(CENTER.x, CENTER.y, 324),
        -- Tile:new(CENTER.x, CENTER.y, 324),
        -- Tile:new(CENTER.x, CENTER.y, 326),
        -- Tile:new(CENTER.x, CENTER.y, 326),
        -- Tile:new(CENTER.x, CENTER.y, 326),
        -- Tile:new(CENTER.x, CENTER.y, 328),
        -- Tile:new(CENTER.x, CENTER.y, 328),
        -- Tile:new(CENTER.x, CENTER.y, 328),
    },
    scared_tile = -1,  -- никакая карта не напугана (не выделена)
    current_triplet_tiles_indexes = {},
    triplets_count = 0,
    buttons={
        Button:new(27*8 + 1, 14*8, 'Zoo'),
        Button:new(23*8 + 3, 15*8 + 7, 'Settings')
    },
}

function game.init()
    -- trace(time())
    math.randomseed(time()*1e7)
    -- shuffle
    for i = #game.tiles, 2, -1 do
        local j = math.random(i)
        local t = game.tiles
        t[i], t[j] = t[j], t[i]
        t[i].x = t[i].x + math.random(-55, 55)
        t[i].y = t[i].y + math.random(-27, 22)
    end
    --
    hand.init()
end

function game.update()
    for _, button in ipairs(game.buttons) do
        local prev_status = button.status
        button:update()
        if button.status == 'pressed' and prev_status ~= 'pressed' then
            -- на кнопку только нажали
        end
    end

    for _, tile in ipairs(game.tiles) do
        tile:update()
    end

    local is_any_tile_held = false  -- для анимации
    for i = #game.tiles, 1, -1 do
        tile = game.tiles[i]
        if tile:in_move_animation() then
            -- пропускаем тайл во время анимации перемещения
            goto continue
        end

        local res = tile:what_are_you_doing_with_me()
        if res == 'hold' then
            is_any_tile_held = true
            tile:set_status('held')
            -- всегда удерживается верхняя карта в таблице
            local temp = table.remove(game.tiles, i)
            table.insert(game.tiles, temp)
            break
        elseif res == 'scare' then
            -- trace(game.scared_tile)
            if game.scared_tile ~= -1 then
                game.tiles[game.scared_tile]:set_status('chill')
            end
            game.scared_tile = i
            game.tiles[game.scared_tile]:set_status('scared')
            break
        elseif res == 'going to hand' then
            tile:set_status('chill')
            tile:set_hand_status('to')  -- nice
            break
        end
        tile:set_status('chill')
        ::continue::
    end

    if is_any_tile_held then
        hand.update_animation()
    else
        -- сбрасываем таймер, чтобы анимация начиналась мгновенно по клику. для перфекционистов
        hand.animation_timer = 0
        hand.cancel_alarm()
    end

    if hand.is_there_a_triplet() then
        local card_counter = 0
        for _, tile in ipairs(game.tiles) do
            if tile.hand_status == 'in' then
                card_counter = card_counter + 1
            end
        end
        -- весь этот card_counter нужен только для того, чтобы триплет засчитывался только после того как закончится анимация
        if card_counter == 3 then
            game.triplets_count = game.triplets_count + 1
            for i = #game.tiles, 1, -1 do
                local tile = game.tiles[i]
                if tile.hand_status == 'in' then
                    -- поднимаем тайл вверх чтобы обезопаситься от бага отрисовки триплетов
                    local temp = table.remove(game.tiles, i)
                    table.insert(game.tiles, temp)

                    table.insert(game.current_triplet_tiles_indexes, i)
                    tile:set_triplet_status('animation')
                end
            end
        end
    end
    game.draw()
end


function game.draw()
    -- cls(15)
    map(0, 0)
    -- hand.draw_hitbox()
    -- hand.draw()
    for _, tile in ipairs(game.tiles) do
        tile:draw()
    end
    for _, button in ipairs(game.buttons) do
        button:draw()
    end
end