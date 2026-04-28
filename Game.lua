CENTER = {x=14*8, y=8*8}
CENTER_AREA = {
    x1 = 9*8 - 1,
    y1 = 6*8 - 1,
    x2 = 15*8 + 4,
    y2 = 9*8 + 4,
}
INVISIBLE_BAR = ProgressBar:new(4*8-1, 1, 4, {body=0, around=0})
INVISIBLE_BAR:set_visibility(false)
LEVEL_BUTTON_X_SIZE = 39

game = {
    tiles = {},
    scared_tile = -1,  -- никакая карта не напугана (не выделена)
    current_triplet_tiles_indexes = {},
    triplets_count = 0,
    buttons = {
        start = Button:new(1, 1*8-3, 'Start'),
        burger = SpriteButton:new(0, 0, {chill=6, scared=38, pressed=70}, 13, 13),
        undo = SpriteButton:new(0, 0, {chill=8, scared=40, pressed=72}, 13, 13),
        levels = Button:new(1, 3*8-3, 'Levels'),
        done = Button:new(20*8, 9*8, 'Done'),
        settings = Button:new(1, 5*8-3, 'Settings'),
        map = Button:new(1, 7*8-3, 'Map'),
        [1] = Button:new(1, 5 + 1*12, '0. [9] ', LEVEL_BUTTON_X_SIZE),
        [2] = Button:new(1, 5 + 2*12, '1. [12]', LEVEL_BUTTON_X_SIZE),
        [3] = Button:new(1, 5 + 3*12, '2. [15]', LEVEL_BUTTON_X_SIZE),
        [4] = Button:new(1, 5 + 4*12, '3. [18]', LEVEL_BUTTON_X_SIZE),
        [5] = Button:new(1, 5 + 5*12, '4. [21]', LEVEL_BUTTON_X_SIZE),
        [6] = Button:new(1, 5 + 6*12, '5. [24]', LEVEL_BUTTON_X_SIZE),
        [7] = Button:new(1, 5 + 7*12, '6. [30]', LEVEL_BUTTON_X_SIZE),
        [8] = Button:new(60, 5 + 1*12, '7. [36]', LEVEL_BUTTON_X_SIZE),
        [9] = Button:new(60, 5 + 2*12, '8. [45]', LEVEL_BUTTON_X_SIZE),
        [10]= Button:new(60, 5 + 3*12, '9. [54]', LEVEL_BUTTON_X_SIZE),
        [11]= Button:new(60, 5 + 4*12, '10. [63]', LEVEL_BUTTON_X_SIZE),
        [12]= Button:new(60, 5 + 5*12, '11. [75]', LEVEL_BUTTON_X_SIZE),
        [13]= Button:new(60, 5 + 6*12, '12. [87]', LEVEL_BUTTON_X_SIZE),
        [14]= Button:new(60, 5 + 7*12, '13. [99]', LEVEL_BUTTON_X_SIZE),
        toggle_sfx = ToggleButton:new(1, 3*8 - 3, 'ON', 'OFF', Settings.SFX, 'sounds'),
        toggle_music = ToggleButton:new(1, 5*8 - 3, 'ON', 'OFF', Settings.MUSIC, 'music'),
        toggle_quick = ToggleButton:new(1, 7*8 - 3, 'ON', 'OFF', Settings.QUICK, 'quick animations'),
    },

    -- невидимый ProgressBar в начале игры
    progress_bar = INVISIBLE_BAR,

    -- количество троек в уровне
    triplets_in_levels = {
        3,
        4,
        5,
        6,
        7,
        8,
        10,
        12,
        15,
        18,
        21,
        25,
        29,
        33,
    },

    current_level = nil,

    spectator = nil,
    scoring_animator = nil,

    status = "levels",
    -- burger — меню, которое выводится при нажатом бургере
    -- settings — игрок в настройках (туду)
    -- levels — игрок в меню выбора уровня
    -- game — основная игра
    -- done — уровень пройден
    -- map — игрок в НОВОМ меню выбора уровня
    prev_statuses = {},  -- таблица, в которой будут храниться предыдущие состояния.

    level_map = LevelMap:new(30, 0)
}

function game.shuffle()
    for i = #game.tiles, 2, -1 do
        local j = math.random(i)
        local t = game.tiles
        t[i], t[j] = t[j], t[i]
        t[i].x = math.random(CENTER_AREA.x1, CENTER_AREA.x2)
        t[i].y = math.random(CENTER_AREA.y1, CENTER_AREA.y2)
        -- t[i].x = t[i].x + math.random(-56, 56)
        -- t[i].y = t[i].y + math.random(-27, 23)

        -- t[i].x = t[i].x + math.random(-20, 20)
        -- t[i].y = t[i].y + math.random(-10, 10)
    end
end

function game.init_level()
    game.prev_statuses = {}  -- чистим историю статусов в начале игры
    hand.clear()

    -- local i = game.current_level
    math.randomseed(time()*1e7)

    -- выбираем случайные value
    game.tiles = {}
    -- см. TileInfo.lua
    local common_bank = table.copy(common_tiles[game.current_level])
    local rare_bank = table.copy(rare_tiles)
    -- сначала добавляем редкие тайлы
    local rare_tiles_count = math.floor(0.28*game.triplets_in_levels[game.current_level])
    for _ = 1, rare_tiles_count do
        local i = math.random(#rare_bank)
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, rare_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, rare_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, rare_bank[i]))
        table.remove(rare_bank, i)
    end
    -- теперь обычные
    for _ = 1, game.triplets_in_levels[game.current_level] - rare_tiles_count do
        local i = math.random(#common_bank)
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, common_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, common_bank[i]))
        table.insert(game.tiles, Tile:new(CENTER.x, CENTER.y, common_bank[i]))
        table.remove(common_bank, i)
    end

    game.shuffle()

    game.progress_bar = ProgressBar:new(3*8-5, 1, game.triplets_in_levels[game.current_level])
    game.spectator = Spectator:new()
end

function game.set_game_visibility(flag)
    -- скрывает или открывает активную игру
    game.progress_bar:set_visibility(flag)
    for _, t in ipairs(game.tiles) do
        t:set_visibility(flag)
    end
end

function game.set_status(status)
    -- перед сменой статуса скрываем все кнопки
    -- а потом включаем только те что нужны
    for _, b in pairs(game.buttons) do
        b:set_visibility(false)
    end


    local is_undo = false
    if status == 'undo' then
        is_undo = true
        status = game.prev_statuses[#game.prev_statuses]
        -- удаляем последний элемент. стек, хули
        table.remove(game.prev_statuses, #game.prev_statuses)
    end

    if status == "levels" then
        game.buttons.undo:set_visibility(true)
        for i = 1, #game.triplets_in_levels do
            game.buttons[i]:set_visibility(true)
        end
    elseif status == 'main' then
        game.buttons.start:set_visibility(true)
        game.buttons.levels:set_visibility(true)
        game.buttons.settings:set_visibility(true)
        game.buttons.map:set_visibility(true)
    elseif status == 'settings' then
        game.buttons.undo:set_visibility(true)
        game.buttons.toggle_sfx:set_visibility(true)
        game.buttons.toggle_music:set_visibility(true)
        game.buttons.toggle_quick:set_visibility(true)
    elseif status == "game" then
        palette.make_normal()  -- делаем палитру нормальной
        game.buttons.burger:set_visibility(true)
        game.score_counter = ScoreCounter:new(22*8+4, 16*8 + 3)
        -- если вернулись в игру, не надо ее инициализировать еще раз
        if not is_undo then
            game.init_level()
        end
    elseif status == "map" then
        game.set_game_visibility(false)
        game.buttons.undo:set_visibility(true)
        palette.make_normal()  -- делаем палитру нормальной
    elseif status == "well done" then  -- анимация done закончилась
        game.buttons.burger:set_visibility(true)
        palette.make_normal()  -- делаем палитру нормальной
    elseif status == "done" then
        game.scoring_animator = ScoringAnimator:new(game.spectator.time, game.spectator.turns)
        game.progress_bar = INVISIBLE_BAR  -- скрываем бар
        game.spectator:hide()  -- скрываем spectator
        -- не спрашивайте, почему одно и то же действие реализовано через два механизма
        -- дело в том, что эти два объекта писали два разных человека
        -- я вчерашний и я сегодняшний

        local clock = 0.6
        local increment_clock = 0.15
        -- for i = #game.tiles, 1, -1 do
        for i = 1, #game.tiles do
            game.tiles[i]:start_score_animation(clock)
            clock = clock + increment_clock
        end
    elseif status == "burger" then
        -- включаем бургерные кнопки
        game.buttons.undo:set_visibility(true)
        game.buttons.map:set_visibility(true)
        game.buttons.levels:set_visibility(true)
        game.buttons.settings:set_visibility(true)
        palette.make_dark()  -- делаем палитру темной
    end
    -- пополняем историю статусов
    -- история чиститься при запуске игры
    if not is_undo then
        table.insert(game.prev_statuses, game.status)
    end
    game.status = status
    
    if game.calc_ministatus() == 'game' then
        game.set_game_visibility(true)
    end
end

function game.init()
    math.randomseed(time()*1e7)

    game.set_status("main")

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
                    name == 8 or
                    name == 9 or
                    name == 10 or
                    name == 11 or
                    name == 12 or
                    name == 13 or
                    name == 14 then
                    game.current_level = name
                    game.set_status("game")
                elseif button.is_toggle then
                    button.is_on = not button.is_on
                    if name == 'toggle_sfx' then
                        Settings.SFX = not Settings.SFX
                    elseif name == 'toggle_music' then
                        Settings.MUSIC = not Settings.MUSIC
                    elseif name == 'toggle_quick' then
                        Settings.QUICK = not Settings.QUICK
                    end
                elseif name == 'burger' then
                    game.set_status('burger')
                elseif name == 'undo' then
                    game.set_status('undo')
                elseif name == 'levels' then
                    game.set_status('levels')
                elseif name == 'settings' then
                    game.set_status('settings')
                elseif name == 'map' then
                    game.set_status('map')
                elseif name == 'start' then
                    game.current_level = 1
                    game.set_status('game')
                -- elseif name == 'done' then
                --     game.set_status('levels')
                end
            end
        end
    end

    if game.status == "map" then
        game.level_map:update()
        if game.level_map:is_going_to_game() then
            game:set_status('game')
        end
    end

    if game.status == "done" then
        -- анимация окончания
        -- все тайлы из прогресс бара идут в зачет
        game.scoring_animator:update(game.tiles)
    end

    for _, tile in ipairs(game.tiles) do
        tile:update()
    end

    if game.status == "game" then
        game.score_counter:update()

        -- проверяем, что игра окончена
        if game.progress_bar:full() then
            -- проверяем, что анимация закончилась
            local flag = true
            for i = #game.tiles, #game.tiles-3, -1 do
                if game.tiles[i].triplet_status ~= "done" then
                    flag = false
                    break
                end
            end
            if flag then
                game.set_status("done")
            end
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
                game.score_counter:triplet()
                Sound.triplet()
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

    if game.spectator and game.status ~= "done" then
        game.spectator:update()
    end

    game.draw()
end


function game.calc_ministatus()
    local mini_status = game.status
    local i_mini_status = #game.prev_statuses + 1
    while true do
        if mini_status == 'burger' or mini_status == 'levels' or mini_status == 'settings' then
            i_mini_status = i_mini_status - 1
            mini_status = game.prev_statuses[i_mini_status]
        else
            break
        end
    end
    return mini_status
end

function game.draw()
    -- cls(15)
    local mini_status = game.calc_ministatus()
    cls(0)
    if mini_status == 'game' then
        map(0, 0)
    elseif mini_status == 'map' then
        game.level_map:draw()
    end
    -- hand.draw_hitbox()
    -- hand.draw()
    game.progress_bar:draw()
    for _, tile in ipairs(game.tiles) do
        tile:draw()
    end
    if game.spectator then
        game.spectator:draw()
    end

    if game.status == "done" then
        local score = game.scoring_animator:get_score_for_tiles()
        if game.scoring_animator:is_end(game.tiles) then
            game.set_status("well done")
        elseif score > 0 then
            print(score, ScoringAnimator.TEXT_SLOTS.tiles.x, ScoringAnimator.TEXT_SLOTS.tiles.y, ScoringAnimator.TEXT_COLOR.tiles)
        end
    elseif mini_status == "well done" then
        local score = game.scoring_animator:get_score_for_tiles()
        -- game.buttons.done:set_visibility(true)
        print("TIME: "..string.format("%.1f", game.scoring_animator.time), ScoringAnimator.TEXT_SLOTS.time.x, ScoringAnimator.TEXT_SLOTS.time.y, ScoringAnimator.TEXT_COLOR.time)
        print("TURNS: "..game.scoring_animator.turns, ScoringAnimator.TEXT_SLOTS.turns.x, ScoringAnimator.TEXT_SLOTS.turns.y, ScoringAnimator.TEXT_COLOR.turns)
        local x = ScoringAnimator.TEXT_SLOTS.score.x
        local y = ScoringAnimator.TEXT_SLOTS.score.y
        local text = "TOTAL SCORE: "
        print(text, x, y, ScoringAnimator.TEXT_COLOR.score)

        x = ScoringAnimator.TEXT_SLOTS.tiles.x
        y = ScoringAnimator.TEXT_SLOTS.tiles.y
        text = score.." "
        print(text, x, y, ScoringAnimator.TEXT_COLOR.tiles)
        x = x + 5*#text + 1

        local turns_score = game.scoring_animator.turns*10
        text = "- "..turns_score.." "
        print(text, x, y, ScoringAnimator.TEXT_COLOR.turns)
        x = x + 5*#text

        local time_score = math.floor(game.scoring_animator.time*10 + 0.5)  -- округление, хули
        text = "- "..time_score
        print(text, x, y, ScoringAnimator.TEXT_COLOR.time)
        x = x + 5*#text

        print(" = "..(score - time_score - turns_score), x, y, ScoringAnimator.TEXT_COLOR.score)
    end

    for _, button in pairs(game.buttons) do
        if button.visibility then
            button:draw()
        end
    end

    if mini_status == 'game' then
        -- print("SCORE: 1234", 22*8+4, 16*8 + 3, 12)
        game.score_counter:draw()
    end
end