game = {
    tiles = {
        Tile:new(40, 40, 256),
        Tile:new(50, 50, 258),
        Tile:new(60, 60, 260),
        Tile:new(70, 70, 262),
        Tile:new(70, 70, 262),
        Tile:new(70, 70, 262),
        -- Tile:new(70, 70, 256),
        -- Tile:new(70, 70, 256),
        -- Tile:new(70, 70, 256),
        -- Tile:new(70, 70, 256),
        -- Tile:new(41, 41, 256),
    },
    scared_tile = -1,  -- никакая карта не напугана (не выделена)
    current_triplet_tiles_indexes = {},
}

function game.init()
    hand.init()
end

function game.update()
    if #game.current_triplet_tiles_indexes == 3 and
        game.tiles[game.current_triplet_tiles_indexes[1]].triplet_status == 'done' and 
        game.tiles[game.current_triplet_tiles_indexes[2]].triplet_status == 'done' and 
        game.tiles[game.current_triplet_tiles_indexes[3]].triplet_status == 'done' then
        for _, i in ipairs(game.current_triplet_tiles_indexes) do
            if game.tiles[i].triplet_status == 'done' then
                -- тайл должен быть удален после триплета
                table.remove(game.tiles, i)
            end
        end
        game.scared_tile = -1
        game.current_triplet_tiles_indexes = {}
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
    end

    if hand.is_there_a_triplet() then
        for i = #game.tiles, 1, -1 do
            local tile = game.tiles[i]
            if tile.hand_status == 'in' then
                table.insert(game.current_triplet_tiles_indexes, i)
                tile:set_triplet_status('animation')
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
end