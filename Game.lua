game = {
    tiles = {
        Tile:new(40, 40, 256),
        Tile:new(40, 40, 256),
        Tile:new(40, 40, 256),
        Tile:new(40, 40, 256),
        -- Tile:new(41, 41, 256),
    },
    scared_tile = -1,  -- никакая карта не напугана (не выделена)
}

function game.update()
    for _, tile in ipairs(game.tiles) do
        tile:update()
    end

    for i = #game.tiles, 1, -1 do
        tile = game.tiles[i]
        local res = tile:what_are_you_doing_with_me()
        if res == 'hold' then
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
        end
        tile:set_status('chill')
    end

    game.draw()
end


function game.draw()
    cls(0)
    -- hand.draw_hitbox()
    -- hand.draw()
    for _, tile in ipairs(game.tiles) do
        tile:draw()
    end
end