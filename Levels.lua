
-- в этом модуле все связанное с уровнями
-- начнем и интерактивной карты уровней. просто чтобы она кликалась и все такое. без функционала
LevelMap = {}

function LevelMap:new(map_x, map_y, size_x, size_y)
    size_x = size_x or 30
    size_y = size_y or 17
    -- при создании карта инициализируется в заданной области. считывает уровни и их нумерацию 
    -- заменяет уровни на карте на кнопки
    -- уровень задается его глобальными координатами на карте
    local object = {
        levels = {},
        events = {},
        show_mode = "donut",
        -- donut — показывает награды за очки
        -- medal — показывает награды за время
    }
    local TILE = {
        [10] = 'normal',  -- обычный уровень
        [74] = 'start',   -- первый доступный уровень
        [42] = 'scoring', -- скоринг-уровень
        [106] = 'secret', -- секретный уровень
        [108] = 'secret-scoring', -- секретный скоринг уровень
    }
    for x = map_x, map_x + size_x do
        for y = map_y, map_y + size_y do
            local tile_type = TILE[mget(x, y)]
            if tile_type then
                table.insert(object.levels, Level:new(x, y, tile_type))
                mset(x, y, 0)
                mset(x+1, y, 0)
                mset(x+1, y+1, 0)
                mset(x, y+1, 0)
            end
        end
    end

    setmetatable(object, self)
    return object
end

function LevelMap:update()
    local flag = false
    for _, level in ipairs(self.levels) do
        if level.state ~= button then
            level:update()
            flag = true
        end
    end
    if flag then
        return
    end

    for _, level in ipairs(self.levels) do
        level:update()
    end
end

function LevelMap:draw()
    map(30, 0)
    for _, level in ipairs(self.levels) do
        level:draw()
    end
    for _, level in ipairs(self.levels) do
        if level.state ~= 'button' then
            level:draw()
        end
    end
end

function LevelMap:is_going_to_game()
    for _, level in ipairs(self.levels) do
        if level.state == 'game' then
            return true
        end
    end
    return false
end

function LevelMap:add_event(event)
    table.insert(self.events, event)
end

LevelMap.__index = LevelMap
--[[
архитектура такая: 
Level — это объект, собирающий в себе всю инфу об уровне + интерактив (кнопка, окно с описанием и статистикой)
LevelMap содержит в себе эти уровни, все апдейты уровней вызываются через него.
В LevelMap есть ивенты — прохождение уровня, улучшение результата. Они ждут своего часа

Идея для секретного уровня: делаем несколько уровней с рукой размером 5, а не 3. И надо собирать пятерки, а не тройки.
Если игрок хорошо пройдет эти уровни (идеально по одному параметру: пончикам или медалям), тогда ему открывается сложный уровень на пятерки.
А после его прохождения открывается скоринговый уровень на пятерки.
Смысл такой: пятерки — интересный, но сложный не-казуальный челлендж.
Если игрок проявит к нему интерес, тогда я награжу его усложненным контентом.
В свою очередь, у игроков, которым пятерки не понравились, на карте НЕ будут отображаться сложные уровни на пятерки
]]

LevelEvent = {}
function LevelEvent:new(event_type, x, y)
    local object = {
        x = x,
        y = y,
        type = event_type,
        -- complete — уровень пройден в первый раз
        -- improve_donut — улучшился результат по очкам
        -- improve_medal — улучшился результат по времени
    }
    setmetatable(object, self)
    return object
end

LevelEvent.__index = LevelEvent

Level = {}
Level.window_box = {x1=4*8-4, y1=2*8-3, x2=26*8+10, y2=14*8+10}
function Level:new(x, y, level_type)
    local object = {
        x = x,
        y = y,
        is_available = (level_type == 'start'),
        is_scoring = (level_type == 'scoring' or level_type == 'secret-scoring'),
        is_secret = (level_type == 'secret' or level_type == 'secret-scoring'),
        state = 'button',
        -- button — уровень в состоянии кнопки
        -- window — игрок открыл окно с описанием уровня
        -- window_to_map
        -- game
        animator = nil,

        window = {
            back_button = Button:new(Level.window_box.x2 - 32, Level.window_box.y2 - 15, 'Back'),
            play_button = SpriteButton:new(Level.window_box.x1 + 6, Level.window_box.y2 - 22,
            {
                chill=420, scared=422, pressed=424,
            },
            16, 16
            ),
        }
    }
    object.disabled_button_sprite = 10
    if object.is_scoring then
        object.disabled_button_sprite = 42
    end

    object.button = SpriteButton:new((x%30)*8, (y%17)*8, {
        chill=74,
        scared=106,
        pressed=138,
    },
    15, 16)
    if object.is_scoring then
        object.button.sprite = {
            chill=76,
            scared=108,
            pressed=140,
        }
    end
    -- все параметры задаются if-ами по x и y уровня.
    local level_code = tostring(x).." "..tostring(y)
    object.id = LEVEL_ID[level_code]  -- номер уровня
    object.name = LEVEL_NAME[level_code]
    object.description = LEVEL_DESCRIPTION[level_code]
    object.pool = LEVEL_POOL[level_code]  -- набор видов, которые могут попасться в этом уровне
    object.diversity = LEVEL_DIVERSITY[level_code]  -- разнообразие видов на уровне
    object.triplets = LEVEL_TRIPLETS[level_code]  -- количество триплетов
    object.layout = LEVEL_LAYOUT[level_code]  -- тип расстановки
    setmetatable(object, self)
    return object
end

function Level:set_state(state)
    if state == 'window' then
        local x = self.x
        local y = self.y
        self.animator = StretchingAnimator:new(
            {
                x1=(x%30)*8,
                y1=(y%17)*8,
                x2=(x%30)*8+7,
                y2=(y%17)*8+7
            },
            Level.window_box)
    elseif state == 'window_to_button' then
        self.animator.is_reverse = true
    end

    self.state = state
end

function Level:update()
    if self.state == 'window' then
        self.button.status = 'chill'  -- мегакостыль
        if not self.animator:is_end() then
            self.animator:update()
        else
            self.window.back_button:update()
            self.window.play_button:update()

            if self.window.back_button:is_pressed() then
                self:set_state('window_to_button')
            elseif self.window.play_button:is_pressed() then
                self:set_state('game')
            end
        end
        return
    end

    if self.state == 'window_to_button' then
        self.animator:update()
        if self.animator:is_end() then
            self:set_state('button')
        end
        return
    end

    if not self.is_available then
        return
    end
    self.button:update()
    if self.button:is_pressed() then
        self:set_state('window')
    end
end

function Level:draw_window(box, c)
    rect(box.x1, box.y1+1, 2, box.y2-box.y1-2, c)
    rect(box.x2-2, box.y1+1, 2, box.y2-box.y1-2, c)
    rect(box.x1+1, box.y1, box.x2-box.x1-2, 2, c)
    rect(box.x1+1, box.y2-2, box.x2-box.x1-2, 2, c)

    rect(box.x1 + 2, box.y1 + 2, 1, 1, c)
    rect(box.x2 - 3, box.y1 + 2, 1, 1, c)
    rect(box.x1 + 2, box.y2 - 3, 1, 1, c)
    rect(box.x2 - 3, box.y2 - 3, 1, 1, c)
end

function Level:draw()
    if self.state == 'window' then
        local box = self.animator.current_box
        rect(box.x1, box.y1, box.x2-box.x1, box.y2-box.y1, 0)        
        local shadow_box = table.copy(box)
        shadow_box.y1 = shadow_box.y1 + 1
        shadow_box.y2 = shadow_box.y2 + 1
        self:draw_window(shadow_box, self.is_scoring and 1 or 5)
        self:draw_window(box, self.is_scoring and 13 or 11)

        if self.animator:is_end() then
            local y = box.y1 + 8
            local dy = 9
            print(tostring(self.id)..'. '..self.name, box.x1 + 6, y, 9)
            y = y + dy
            for _, line in ipairs(self.description) do
                print(line, box.x1 + 6, y)
                y = y + dy
            end
            self.window.back_button:draw()
            self.window.play_button:draw()
        end
        return
    end

    if self.state == 'window_to_button' then
        local box = self.animator.current_box
        rect(box.x1, box.y1, box.x2-box.x1, box.y2-box.y1, 0)        
        local shadow_box = table.copy(box)
        shadow_box.y1 = shadow_box.y1 + 1
        shadow_box.y2 = shadow_box.y2 + 1
        self:draw_window(shadow_box, self.is_scoring and 1 or 5)
        self:draw_window(box, self.is_scoring and 13 or 11)
        return
    end

    if self.is_available then
        self.button:draw()
        if self.button.status ~= 'chill' then
            print(tostring(self.id)..'. '..self.name, 0, 16*8)
        end
    else
        if self.is_secret then
            return
        end
        local x = self.x % 30
        local y = self.y % 17
        local width = 2
        local height = 2
        spr(self.disabled_button_sprite, x*8, y*8, 0, 1,0,0, width,height)
    end
end

Level.__index = Level