
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
    for _, level in ipairs(self.levels) do
        level:update()
    end
end

function LevelMap:draw()
    map(30, 0)
    for _, level in ipairs(self.levels) do
        level:draw()
    end
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
function Level:new(x, y, level_type)
    local object = {
        x = x,
        y = y,
        is_available = (level_type == 'start'),
        is_scoring = (level_type == 'scoring' or level_type == 'secret-scoring'),
        is_secret = (level_type == 'secret' or level_type == 'secret-scoring'),
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
    local level_id = tostring(x).." "..tostring(y)
    object.name = LEVEL_NAME[level_id]
    object.description = LEVEL_DESCRIPTION[level_id]
    object.pool = LEVEL_POOL[level_id]  -- набор видов, которые могут попасться в этом уровне
    object.diversity = LEVEL_DIVERSITY[level_id]  -- разнообразие видов на уровне
    object.triplets = LEVEL_TRIPLETS[level_id]  -- количество триплетов
    object.layout = LEVEL_LAYOUT[level_id]  -- тип расстановки
    setmetatable(object, self)
    return object
end

function Level:update()
    if self.is_available then
        self.button:update()
    end
end

function Level:draw()
    if self.is_available then
        self.button:draw()
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