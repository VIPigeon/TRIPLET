pink_seed = 0  -- уже не нужно

CENTER = {x=14*8, y=8*8}
-- CENTER_AREA = {  -- теперь в Levels.lua
--     x1 = 9*8 - 1,
--     y1 = 6*8 - 1,
--     x2 = 15*8 + 4,
--     y2 = 9*8 + 4,
-- }
INVISIBLE_BAR = ProgressBar:new(4*8-1, 1, 4, {body=0, around=0}, false)
-- INVISIBLE_BAR:set_visibility(false)
LEVEL_BUTTON_X_SIZE = 39

game = {
    animation_modificator = 1,  -- чтобы игрок мог "скипнуть" анимацию получения очков

    circles = {},

    well_done_t = 0, -- для анимации well_done
    well_done_T = 0.85, -- для анимации well_done
    well_done_state = false, -- для анимации well_done

    tiles = {},
    scared_tile = -1,  -- никакая карта не напугана (не выделена)
    current_triplet_tiles_indexes = {},
    triplets_count = 0,
    buttons = {
        start = Button:new(19*8, 11*8, 'Start', nil, nil, nil, 1),
        -- burger = SpriteButton:new(0, 0, {chill=6, scared=38, pressed=70}, 12, 13),
        settings = SpriteButton:new(0, 0, {chill=6, scared=38, pressed=70}, 12, 13),
        undo = SpriteButton:new(0, 0, {chill=8, scared=40, pressed=72}, 12, 13),
        -- levels = Button:new(1, 3*8-3, 'Levels'),
        done = Button:new(20*8, 9*8, 'Done'),
        -- settings = Button:new(1, 5*8-3, 'Settings'),
        map = Button:new(19*8 + 6, 14*8, 'Map', nil,nil,nil, 1),
        from_level_to_map = SpriteButton:new(2*8, 0, {chill=130, scared=132, pressed=134}, 12, 13),
        from_map_to_level = SpriteButton:new(2*8, 0, {chill=64, scared=66, pressed=68}, 12, 13),
        -- [1] = Button:new(1, 5 + 1*12, '0. [9] ', LEVEL_BUTTON_X_SIZE),
        -- [2] = Button:new(1, 5 + 2*12, '1. [12]', LEVEL_BUTTON_X_SIZE),
        -- [3] = Button:new(1, 5 + 3*12, '2. [15]', LEVEL_BUTTON_X_SIZE),
        -- [4] = Button:new(1, 5 + 4*12, '3. [18]', LEVEL_BUTTON_X_SIZE),
        -- [5] = Button:new(1, 5 + 5*12, '4. [21]', LEVEL_BUTTON_X_SIZE),
        -- [6] = Button:new(1, 5 + 6*12, '5. [24]', LEVEL_BUTTON_X_SIZE),
        -- [7] = Button:new(1, 5 + 7*12, '6. [30]', LEVEL_BUTTON_X_SIZE),
        -- [8] = Button:new(60, 5 + 1*12, '7. [36]', LEVEL_BUTTON_X_SIZE),
        -- [9] = Button:new(60, 5 + 2*12, '8. [45]', LEVEL_BUTTON_X_SIZE),
        -- [10]= Button:new(60, 5 + 3*12, '9. [54]', LEVEL_BUTTON_X_SIZE),
        -- [11]= Button:new(60, 5 + 4*12, '10. [63]', LEVEL_BUTTON_X_SIZE),
        -- [12]= Button:new(60, 5 + 5*12, '11. [75]', LEVEL_BUTTON_X_SIZE),
        -- [13]= Button:new(60, 5 + 6*12, '12. [87]', LEVEL_BUTTON_X_SIZE),
        -- [14]= Button:new(60, 5 + 7*12, '13. [99]', LEVEL_BUTTON_X_SIZE),
        -- ok = Button:new(25*8, 14*8, 'OK', nil,nil,nil, 1),
        ok = SpriteButton:new(17*8 + 3, 12*8 - 3, {chill=420, scared=422, pressed=424}, 16, 16),
        ok_tutorial = Button:new(21*8, 12*8, 'OK', nil,nil,nil, 1),

        -- определяется в init
        -- toggle_sfx = ToggleButton:new(1, 3*8 - 3, 'ON', 'OFF', Settings.SFX, 'sounds'),
        -- toggle_music = ToggleButton:new(1, 5*8 - 3, 'ON', 'OFF', Settings.MUSIC, 'music'),
        -- toggle_quick = ToggleButton:new(1, 7*8 - 3, 'ON', 'OFF', Settings.QUICK, 'quick animations'),
        -- toggle_time = ToggleButton:new(1, 9*8 - 3, 'ON', 'OFF', Settings.SHOW_TIME_DURING_GAME, 'show time'),

        change_mode_button = ToggleButton:new(0, 18, 'best score', ' best time', true, nil,nil,nil,
            { -- 4*8, 4
            text = {[true]=4, [false]=4},
            chill = {[true]=10, [false]=10},
            scared= {[true]=15, [false]=15},
            -- pressed={[true]=3, [false]=11},
            pressed={[true]=14, [false]=14},
            shadow = {[true]=4, [false]=4},
            }
        ),
    },

    -- невидимый ProgressBar в начале игры
    progress_bar = INVISIBLE_BAR,

    -- количество троек в уровне
    -- triplets_in_levels = {
    --     3,
    --     4,
    --     5,
    --     6,
    --     7,
    --     8,
    --     10,
    --     12,
    --     15,
    --     18,
    --     21,
    --     25,
    --     29,
    --     33,
    -- },

    current_level = nil,

    spectator = nil,
    scoring_animator = nil,

    status = "main",
    -- settings — игрок в настройках (туду)
    -- game — основная игра
    -- done — уровень пройден
    -- map — игрок в НОВОМ меню выбора уровня
    prev_statuses = {},  -- таблица, в которой будут храниться предыдущие состояния.

    level_map = LevelMap:new(30, 0),
    change_screen_animation = nil,  -- обрабатывается параллельно
}

-- TODO: переместить в нормальное место
function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

function game.init_level()
    game.prev_statuses = {}  -- чистим историю статусов в начале игры
    game.current_level:set_board()
    hand.clear()
    hand.init()
    game.scared_tile = -1

    if game.current_level.name == 'DEJA VU' then
        -- trace('DEJA VU')
        math.randomseed(67)
    else
        math.randomseed(time()*1e7)
    end

    game.tiles = game.current_level:get_tiles()
    -- for _, t in ipairs(game.tiles) do
    --     trace(t.value)
    -- end
    -- trace(#game.tiles)
    shuffle(game.tiles)
    -- TODO: сделать анимацию
    for i, point in ipairs(game.current_level:get_layout()) do
        game.tiles[i].x = point.x
        game.tiles[i].y = point.y
    end
    game.progress_bar = ProgressBar:new(4*8, 0, game.current_level:get_triplets())
    game.spectator = Spectator:new()
end

--[[
function game.init_numbered_level()  -- BACKUP
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

    shuffle(game.tiles)

    game.progress_bar = ProgressBar:new(3*8-5, 1, game.triplets_in_levels[game.current_level])
    game.spectator = Spectator:new()
end
]]

function game.set_game_visibility(flag)
    -- скрывает или открывает активную игру
    game.progress_bar:set_visibility(flag)
    for _, t in ipairs(game.tiles) do
        t:set_visibility(flag)
    end
end

function game.is_change_screen(status)
    if game.status == 'settings' or status == 'settings' then
        return false
    elseif game.status == status then
        return false
    elseif status == 'done' or status == 'well done' then
        return false
    end
    return true
    -- if status == 'game' and game.status == 'map' then
    --     return true
    -- elseif status == 'map' and game.status == 'game' then
    --     return true
    -- end
end

function game.set_status(status)
    if game.change_screen_animation and game.change_screen_animation:is_middle() then
        -- pass
    else
        if game.is_change_screen(status) then
            game.change_screen_animation = ChangeScreenAnimator:new()
            game.backlog_status = status
            return
        end
    end

    -- перед сменой статуса скрываем все кнопки
    -- а потом включаем только те что нужны
    for _, b in pairs(game.buttons) do
        b:set_visibility(false)
    end

    if game.status == 'settings' then
        palette.make_normal()  -- делаем палитру нормальной при ВЫХОДЕ из settings
    end


    local is_undo = false
    if status == 'undo' then
        is_undo = true
        status = game.prev_statuses[#game.prev_statuses]
        -- удаляем последний элемент. стек, хули
        table.remove(game.prev_statuses, #game.prev_statuses)
    end
    -- local debug_text = ''
    -- if is_undo then
    --     debug_text = 'undo'
    -- end
    -- trace(debug_text..' '..status..tostring(#game.tiles))

    -- if status == "levels" then
    --     game.buttons.undo:set_visibility(true)
    --     for i = 1, #game.triplets_in_levels do
    --         game.buttons[i]:set_visibility(true)
    --     end
    if status == 'main' then
        game.buttons.start:set_visibility(true)
        -- game.buttons.levels:set_visibility(true)
        game.buttons.settings:set_visibility(true)
        game.buttons.map:set_visibility(true)

        -- game.tutorial:init()
    elseif status == 'settings' then
        palette.make_dark()  -- делаем палитру темной
        game.buttons.undo:set_visibility(true)
        game.buttons.toggle_sfx:set_visibility(true)
        game.buttons.toggle_music:set_visibility(true)
        game.buttons.toggle_quick:set_visibility(true)
        game.buttons.toggle_time:set_visibility(true)

        if game.status == 'well done' then
            game.buttons.ok:set_visibility(true)
        end
    elseif status == "game" then
        if game.current_level.name == 'ROSE-TINTED' then
            palette.set_color('pink')
            pink_seed = pink_seed + 1
        else
            palette.set_color('green')
        end

        -- game.buttons.burger:set_visibility(true)
        game.buttons.settings:set_visibility(true)
        game.buttons.from_level_to_map:set_visibility(true)
        -- если вернулись в игру, не надо ее инициализировать еще раз
        if not is_undo then
            game.init_level()
            game.score_counter = ScoreCounter:new()
        end
    elseif status == "map" then
        palette.set_color('green')

        game.set_game_visibility(false)
        game.buttons.settings:set_visibility(true)
        -- trace(game.status)
        if game.status == 'game' then
            game.buttons.from_map_to_level:set_visibility(true)
        end
        game.buttons.change_mode_button:set_visibility(true)
        palette.make_normal()  -- делаем палитру нормальной
        game.level_map:process_events()
    elseif status == "well done" then  -- анимация done закончилась
        game.buttons.settings:set_visibility(true)
        game.buttons.ok:set_visibility(true)
        palette.make_normal()  -- делаем палитру нормальной
    elseif status == "done" then
        mem.save()

        game.scoring_animator = ScoringAnimator:new(game.spectator.time, game.spectator.turns)
        game.progress_bar = INVISIBLE_BAR  -- скрываем бар
        game.spectator:hide()  -- скрываем spectator
        -- не спрашивайте, почему одно и то же действие реализовано через два механизма
        -- дело в том, что эти два объекта писали два разных человека
        -- я вчерашний и я сегодняшний

        local clock = 0.6
        local increment_clock = 0.15
        local TILE_SIZE = 14 + (5) -- с отступом

        local slot_i = 1
        local _X = 104
        local _Y = 27
        local TILE_Y = 16
        local TILE_X = 16
        local slots = {
            {x=_X, y = _Y},
            {x=_X, y = _Y + TILE_Y},
            {x=_X, y = _Y + TILE_Y*2},
            {x=_X, y = _Y + TILE_Y*3},
            {x=_X - TILE_X, y = _Y + TILE_Y/2},
            {x=_X - TILE_X, y = _Y + TILE_Y/2 + TILE_Y},
            {x=_X - TILE_X, y = _Y + TILE_Y/2 + TILE_Y*2},
            {x=_X - TILE_X, y = _Y + TILE_Y/2 + TILE_Y*3},

            {x=_X - TILE_X*2, y = _Y},
            {x=_X - TILE_X*2, y = _Y + TILE_Y},
            {x=_X - TILE_X*2, y = _Y + TILE_Y*2},
            {x=_X - TILE_X*2, y = _Y + TILE_Y*3},
            {x=_X - TILE_X*3, y = _Y + TILE_Y/2},
            {x=_X - TILE_X*3, y = _Y + TILE_Y/2 + TILE_Y},
            {x=_X - TILE_X*3, y = _Y + TILE_Y/2 + TILE_Y*2},
            {x=_X - TILE_X*3, y = _Y + TILE_Y/2 + TILE_Y*3},

            {x=_X - TILE_X*4, y = _Y},
            {x=_X - TILE_X*4, y = _Y + TILE_Y},
            {x=_X - TILE_X*4, y = _Y + TILE_Y*2},
            {x=_X - TILE_X*4, y = _Y + TILE_Y*3},
            {x=_X - TILE_X*5, y = _Y + TILE_Y/2},
            {x=_X - TILE_X*5, y = _Y + TILE_Y/2 + TILE_Y},
            {x=_X - TILE_X*5, y = _Y + TILE_Y/2 + TILE_Y*2},
            {x=_X - TILE_X*5, y = _Y + TILE_Y/2 + TILE_Y*3},
        }

        -- local SCORE_SLOT = {x=10, y=14*8 - 2}
        -- local slot = table.copy(SCORE_SLOT)
        local COUNTER = 6 -- количество тайлов в ряду
        local counter = COUNTER
        local _TRIPLET_SIZE = 3
        if string.find(game.current_level.name, 'TAKE FIVE') then
            _TRIPLET_SIZE = 5
        end
        for i = 1, #game.tiles do
            game.tiles[i]:start_score_animation(clock, slots[slot_i])
            clock = clock + increment_clock
            if i % _TRIPLET_SIZE == 0 then
                slot_i = slot_i + 1
                -- slot.x = slot.x + TILE_SIZE
                -- counter = counter - 1
                -- if counter == 0 then
                --     counter = COUNTER
                --     slot.x = SCORE_SLOT.x
                --     slot.y = slot.y - TILE_SIZE
                -- end
            end
        end
    end
    -- пополняем историю статусов
    -- история чиститься при запуске игры
    if not is_undo then
        table.insert(game.prev_statuses, game.status)
    end
    game.status = status
    
    -- if game.calc_ministatus() == 'game' then
    if game.calc_ministatus() == 'game' or game.calc_ministatus() == 'done' or game.calc_ministatus() == 'well done' then
        game.set_game_visibility(true)
    end
end

function game.init()
    math.randomseed(time()*1e7)

    -- game.tutorial = Tutorial:new()

    -- mem.clear()

    if not ALL_LEVELS_AVAILABLE then
        mem.load() -- SaveAndLoad
    end
    for _, level in ipairs(game.level_map.levels) do
        if level.name == FIRST_LEVEL_NAME then
            level.is_available = true
        end
    end

    game.buttons.toggle_sfx = ToggleButton:new(1, 3*8 - 3, 'ON', 'OFF', Settings.SFX, 'sounds')
    game.buttons.toggle_music = ToggleButton:new(1, 5*8 - 3, 'ON', 'OFF', Settings.MUSIC, 'music')
    game.buttons.toggle_quick = ToggleButton:new(1, 7*8 - 3, 'ON', 'OFF', Settings.QUICK, 'quick animations')
    game.buttons.toggle_time = ToggleButton:new(1, 9*8 - 3, 'ON', 'OFF', Settings.SHOW_TIME_DURING_GAME, 'show time')

    game.set_status("main")

    hand.init()
end

function game.is_black(x, y)
    for dx = -7, 7 do
        for dy = -7, 7 do
            if pix(x+dx, y+dy) ~= 0 then
                return false
            end
        end
    end
    return true
end

function game.circles_update()
    local x, y, left, middle, right = mouse()
    local flag = game.is_black(x, y)
    if flag and Click.left() then
        table.insert(game.circles, CircleOnTheWater:new(x, y, 1))
    elseif flag and Click.right() then
        table.insert(game.circles, CircleOnTheWater:new(x, y, 5))
    end

    local should_remove = {}
    for i, c in ipairs(game.circles) do
        c:update()
        if c.r > 250 then
            table.insert(should_remove, i)
        end
    end

    for j = #should_remove, 1, -1 do
        local i = should_remove[j]
        table.remove(game.circles, i)
    end
end

function game.update()

    mem.save()

    game.circles_update()

    if game.change_screen_animation then
        game.change_screen_animation:update()
        if game.change_screen_animation:is_middle() and not game.change_screen_flag then
            game.set_status(game.backlog_status)
            game.change_screen_flag = true
        elseif game.change_screen_animation:is_end() then
            game.change_screen_flag = false
            game.change_screen_animation = false
        end
        game.draw()
        return
    end
    for _, tile in ipairs(game.tiles) do
        tile:update()
    end

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
                    -- game.current_level = name
                    -- game.set_status("game")
                elseif button.is_toggle then
                    button.is_on = not button.is_on
                    if name == 'toggle_sfx' then
                        Settings.SFX = not Settings.SFX
                    elseif name == 'toggle_music' then
                        Settings.MUSIC = not Settings.MUSIC
                    elseif name == 'toggle_quick' then
                        Settings.QUICK = not Settings.QUICK
                    elseif name == 'toggle_time' then
                        Settings.SHOW_TIME_DURING_GAME = not Settings.SHOW_TIME_DURING_GAME
                    elseif name == 'change_mode_button' then
                        if game.level_map.show_mode == 'donut' then
                            game.level_map.show_mode = 'medal'
                        else
                            game.level_map.show_mode = 'donut'
                        end
                    end
                -- elseif name == 'burger' then
                --     game.set_status('burger')
                elseif name == 'undo' or name == 'from_map_to_level' then
                    game.set_status('undo')
                -- elseif name == 'levels' then
                --     game.set_status('levels')
                elseif name == 'settings' then
                    game.set_status('settings')
                elseif name == 'map' or name == 'from_level_to_map' then
                    game.set_status('map')
                elseif name == 'start' then
                    game.current_level = game.level_map:get_available_level()
                    game.set_status('game')
                -- elseif name == 'done' then
                --     game.set_status('levels')
                elseif name == 'ok' then
                    local x = game.current_level.x
                    local y = game.current_level.y
                    local time = game.spectator.time
                    local score = game.spectator.turns  -- TODO: заменить на очки за комбо
                    local complete = LevelEvent:new('complete', x, y)
                    game.level_map:add_event(complete)
                    game.current_level.is_completed = true

                    game.set_status('map')
                end
            end
        end
    end

    if game.status == "map" then
        game.level_map:update()
        local current_level = game.level_map:get_starting_level()
        if current_level then
            game.current_level = current_level
            game.set_status('game')
        end
    end

    if game.status == "done" then
        -- анимация окончания
        local x, y, left, middle, right = mouse()
        -- Фейковое ускорение. На самом деле я просто делаю столько апдейтов, какой модификатор с округлением вниз
        -- local ACCELERATION = 0.1
        -- if left or right then
        --     game.animation_modificator = math.min(game.animation_modificator + ACCELERATION, 7)
        -- else
        --     game.animation_modificator = math.max(game.animation_modificator - ACCELERATION*3, 1)
        -- end

        -- все тайлы из прогресс бара идут в зачет
        game.scoring_animator:update(game.tiles)
    end

    -- for _, tile in ipairs(game.tiles) do
    --     tile:update()
    -- end

    if game.status == "game" then
        game.score_counter:update()

        -- проверяем, что игра окончена
        if game.progress_bar:full() then
            -- проверяем, что анимация закончилась
            local flag = true
            -- for i = #game.tiles, #game.tiles-3, -1 do
            local _TRIPLET_SIZE = 3
            if string.find(game.current_level.name, 'TAKE FIVE') then
                _TRIPLET_SIZE = 5
            end
            for i = #game.tiles, #game.tiles-_TRIPLET_SIZE+1, -1 do
                if game.tiles[i].triplet_status ~= "done" then
                    flag = false
                    break
                end
            end
            if flag then
                game.set_status("done")
            end
        end

        local is_any_tile_held = false
        local is_any_tile_going_to_hand = false
        for i = #game.tiles, 1, -1 do
            tile = game.tiles[i]
            if tile:in_move_animation() then
                -- пропускаем тайл во время анимации перемещения
                goto continue
            end

            local res = tile:what_are_you_doing_with_me()
            if res == 'hold' then
                if tile.hand_status == 'from' then
                    hand.tile_from_hand_status = 'hold'
                end

                is_any_tile_held = true
                tile:set_status('held')
                -- всегда удерживается верхняя карта в таблице
                local temp = table.remove(game.tiles, i)
                table.insert(game.tiles, temp)
                break
            elseif res == 'scare' then
                if game.scared_tile ~= -1 then
                    game.tiles[game.scared_tile]:set_status('chill')
                end
                game.scared_tile = i
                game.tiles[game.scared_tile]:set_status('scared')
                break
            elseif res == 'going to hand' then
                is_any_tile_going_to_hand = true
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
            local _TRIPLET_SIZE = 3
            if string.find(game.current_level.name, 'TAKE FIVE') then
                _TRIPLET_SIZE = 5
            end
            if card_counter == _TRIPLET_SIZE then
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

        if not is_any_tile_held then
            if hand.tile_from_hand_status == 'hold' then
                if is_any_tile_going_to_hand then
                    hand.tile_from_hand_status = 'chill'
                else
                    hand.tile_from_hand_status = 'drop'
                end
            else
                hand.tile_from_hand_status = 'chill'
            end
        end
    end

    if game.spectator and game.status ~= "done" then
        game.spectator:update()
    end

    -- trace(tostring(is_any_tile_held)..' '..hand.tile_from_hand_status)

    game.draw()
end


function game.calc_ministatus()
    local mini_status = game.status
    local i_mini_status = #game.prev_statuses + 1
    while true do
        -- if mini_status == 'burger' or mini_status == 'levels' or mini_status == 'settings' then
        if mini_status == 'settings' then
            i_mini_status = i_mini_status - 1
            mini_status = game.prev_statuses[i_mini_status]
        else
            break
        end
    end
    return mini_status
end

function game.print_funny_phrase()
    -- я убил эту функцию
    local PHRASES = {
        'BELIEVE',
        -- 'I LOVE U',
        -- 'CARPA DIEM!',
        -- ...
    }
    math.randomseed(pink_seed)
    local text = PHRASES[math.random(1, #PHRASES)]
    local c = 5
    local x1 = game.current_level.layout.x1 + 8
    local x2 = math.max(x1, game.current_level.layout.x2 - math.floor(4.3 * #text))
    local y1 = game.current_level.layout.y1 + 8
    local y2 = game.current_level.layout.y2 + 1
    local x = math.random(x1, x2)
    local y = math.random(y1, y2)
    -- print(text, x, y, c)
    math.randomseed(time()*1e7)
end

function game.draw()
    -- cls(15)
    local mini_status = game.calc_ministatus()
    cls(0)

    for _, c in ipairs(game.circles) do
        c:draw()
    end

    if mini_status == 'game' then
        map(0, 0, 30,17,0,0, 0)
        if game.current_level.name == 'ROSE-TINTED' then
            game.print_funny_phrase()
        end
    elseif mini_status == 'map' then
        game.level_map:draw()
    elseif mini_status == 'main' then
        map(30, 0, 30,17,0,0, 0)

        local MAIN_COLOR = 11
        local OUTLINE_COLOR = 5
        local TEXT = "TRIPLET!"
        local OUTLINE_WIDTH = 1
        local X = 5*8
        local Y = 4*8
        local SIZE = 4
        local function pprint(X, Y, MAIN_COLOR)
            print(TEXT, X-OUTLINE_WIDTH, Y, MAIN_COLOR, false, SIZE)
            print(TEXT, X+OUTLINE_WIDTH, Y, MAIN_COLOR, false, SIZE)
            print(TEXT, X, Y-OUTLINE_WIDTH, MAIN_COLOR, false, SIZE)
            print(TEXT, X, Y+OUTLINE_WIDTH, MAIN_COLOR, false, SIZE)
        end

        pprint(X, Y+4, OUTLINE_COLOR)
        pprint(X, Y-4, OUTLINE_COLOR)
        pprint(X+4, Y, OUTLINE_COLOR)
        pprint(X-4, Y, OUTLINE_COLOR)

        pprint(X+3, Y+2, OUTLINE_COLOR)
        pprint(X+2, Y+3, OUTLINE_COLOR)

        pprint(X+3, Y-2, OUTLINE_COLOR)
        pprint(X+2, Y-3, OUTLINE_COLOR)

        pprint(X-3, Y-2, OUTLINE_COLOR)
        pprint(X-2, Y-3, OUTLINE_COLOR)

        pprint(X-3, Y+2, OUTLINE_COLOR)
        pprint(X-2, Y+3, OUTLINE_COLOR)

        pprint(X, Y, MAIN_COLOR)
        
    end

    -- hand.draw_hitbox()
    -- hand.draw()

    if mini_status == 'game' then
        -- print("SCORE: 1234", 22*8+4, 16*8 + 3, 12)
        game.score_counter:draw()
        if game.spectator then
            game.spectator:draw()
        end
    end
    game.progress_bar:draw()
    for _, tile in ipairs(game.tiles) do
        tile:draw()
    end

    if game.status == "done" then
        local score = game.scoring_animator:get_score_for_tiles()
        if game.scoring_animator:is_end(game.tiles) then
            game.set_status("well done")
        -- elseif score > 0 then
        --     print(score, ScoringAnimator.TEXT_SLOTS.tiles.x, ScoringAnimator.TEXT_SLOTS.tiles.y, ScoringAnimator.TEXT_COLOR.tiles)
        end
    elseif mini_status == "well done" then
        local score = game.score_counter:get_score()
        local time = game.scoring_animator.time

        -- пока что медаль и пончик выдаем прямо здесь
        game.current_level:improve_result(time, score)
        local medal = game.current_level:get_medal(time)
        local donut = game.current_level:get_donut(score)

        game.well_done_t = Basic.tick_timer(game.well_done_t)
        if game.well_done_t == 0 then
            game.well_done_t = game.well_done_T
            game.well_done_state = not game.well_done_state
        end

        local X = 17*8 + 2 + 9
        local Y = 5*8 + 1
        local dY = 0
        if game.well_done_state then
            dY = -1
        end
        -- local DX = 39
        local mDX = 12
        print('score: '..tostring(score), X, Y)
        -- spr(donut, X, Y + 8)
        spr(donut, X - mDX, Y - 1 + dY)
        -- print(score, X + 16, Y + 10)
        -- print(score, X + DX, Y)
        print('time: '..string.format("%.1f", time), X, Y + 3*8)
        -- spr(medal, X, Y + 4*8)
        spr(medal, X - mDX, Y + 3*8 - 1 + dY)
        -- print(string.format("%.1f", time), X + 16, Y + 4*8 + 2)
        -- print(string.format("%.1f", time), X + DX, Y + 3*8)
        --[[
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
        ]]
    end

    for _, button in pairs(game.buttons) do
        if button.visibility then
            button:draw()
        end
    end

    if game.status == 'game' or game.status == 'done' or game.status == 'well done' then
        game.current_level:print_name()
    end

    if game.change_screen_animation then
        -- trace(game.change_screen_animation.x)
        game.change_screen_animation:draw()
    end

end