CENTER = {x=14*8, y=8*8}

game = {
    tiles = {},
    scared_tile = -1,  -- никакая карта не напугана (не выделена)
    current_triplet_tiles_indexes = {},
    triplets_count = 0,
    buttons = {
        burger = SpriteButton:new(0, 0, {chill=6, scared=38, pressed=70}, 13, 13),
        zoo = Button:new(27*8+1, 15*8 + 7, 'Zoo'),
        levels = Button:new(12*8+5, 15*8 + 7, 'Levels'),
        settings = Button:new(1, 15*8 + 7, 'Settings'),
        -- ToggleButton:new(2, 20, 'ON', 'OFF'),  -- тоггл моей мечты
        [1] = Button:new(7*8, 4*8, '1. [9] '),
        [2] = Button:new(7*8, 6*8, '2. [21]'),
        [3] = Button:new(7*8, 8*8, '3. [33]'),
        [4] = Button:new(7*8, 10*8, '4. [45]'),
        [5] = Button:new(19*8, 4*8, '5. [57]'),
        [6] = Button:new(19*8, 6*8, '6. [69]'),
        [7] = Button:new(19*8, 8*8, '7. [81]'),
        [8] = Button:new(19*8, 10*8, '8. [99]'),
    },

    -- невидимый ProgressBar в начале игры
    progress_bar = ProgressBar:new(4*8-1, 1, 4, {body=0, around=0}),

    levels = {
        3,
        7,
        11,
        15,
        19,
        23,
        27,
        31,
    },

    current_level = nil,

    status = "levels",
    -- burger — меню, которое выводится при нажатом бургере
    -- settings — игрок в настройках (туду)
    -- levels — игрок в меню выбора уровня
    -- zoo — игрок смотрит свою коллекцию (туду)
    -- game — основная игра
}

function game.shuffle()
    for i = #game.tiles, 2, -1 do
        local j = math.random(i)
        local t = game.tiles
        t[i], t[j] = t[j], t[i]
        t[i].x = t[i].x + math.random(-56, 56)
        t[i].y = t[i].y + math.random(-27, 23)
    end
end

function game.init_level()
    -- local i = game.current_level
    math.randomseed(time()*1e7)

    -- выбираем случайные value
    game.tiles = {}
    -- см. TileInfo.lua
    local common_bank = table.copy(common_tiles[game.current_level])
    local rare_bank = table.copy(rare_tiles)
    -- сначала добавляем редкие тайлы
    for _ = 1, game.current_level - 1 do
        local i = math.random(#rare_bank)
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, rare_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, rare_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, rare_bank[i]))
        table.remove(rare_bank, i)
    end
    -- теперь обычные
    for _ = 1, game.levels[game.current_level] - (game.current_level - 1) do
        local i = math.random(#common_bank)
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, common_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, common_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, common_bank[i]))
        table.remove(common_bank, i)
    end

    game.shuffle()

    game.progress_bar = ProgressBar:new(4*8-1, 1, game.levels[game.current_level])
end

function game.set_status(status)
    -- перед сменой статуса скрываем все кнопки
    -- а потом включаем только те что нужны
    for _, b in pairs(game.buttons) do
        b:set_visibility(false)
    end

    if status == "levels" then
        for i = 1, #game.levels do
            game.buttons[i]:set_visibility(true)
        end
    elseif status == "game" then
        game.buttons.burger:set_visibility(true)
        game.init_level()
    end
    game.status = status
end

function game.init()
    math.randomseed(time()*1e7)

    game.set_status("levels")

    hand.init()
end

function game.update()
    for name, button in pairs(game.buttons) do
        if button.visibility then
            local prev_status = button.status
            button:update()
            local x, y, left, middle, right = mouse()
            if button.status ~= 'pressed' and prev_status == 'pressed' and not left then
                -- реагируем на отпускание кнопки

                -- ЛЕГЕНДАРНО
                if name == 1 or
                    name == 2 or
                    name == 3 or
                    name == 4 or
                    name == 5 or
                    name == 6 or
                    name == 7 or
                    name == 8 then
                    game.current_level = name
                    game.set_status("game")
                end
                if button.is_toggle then
                    button.is_on = not button.is_on
                end
            end
        end
    end

    for _, tile in ipairs(game.tiles) do
        tile:update()
    end

    if game.status == "game" then
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
                game.progress_bar:add()  -- смещаем tile_slot
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
    end

    game.draw()
end


function game.draw()
    -- cls(15)
    if game.status == "game" then
        map(0, 0)
    elseif game.status == "levels" then
        map(30, 0)
    end
    -- hand.draw_hitbox()
    -- hand.draw()
    game.progress_bar:draw()
    for _, tile in ipairs(game.tiles) do
        tile:draw()
    end
    for _, button in pairs(game.buttons) do
        if button.visibility then
            button:draw()
        end
    end
end