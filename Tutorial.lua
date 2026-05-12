
-- делаем видео-туториал по управлению
-- он же и будет вступительным экраном,
-- так что лишней работы не будет
--[[
состав туториала:
+ мышка в правой части экрана
    - показывает что мы нажимаем/удерживаем
+ автоматический курсор, которы действует по скрипту
    - всегда делает одни и те же действия
+ мини-уровень
    - 9 тайлов 3-x3
    - сами виды и их положение рандомизировано
        * но порядок сверху-вниз фиксирован
]]


AutoCursor = {
    x = 0,
    y = 0,
    left = false,
    right = false,
}

function AutoCursor.draw()
    spr(450, AutoCursor.x, AutoCursor.y, 0)
end

function tutor_mouse()
    return AutoCursor.x, AutoCursor.y, AutoCursor.left, false, AutoCursor.right
end

-- тот же тайл, но реагирует только на автокурсор вместо игрока
TutorTile = table.copy(Tile)

function TutorTile:move_by_cursor()
    -- если тайл удерживается, он двигается вместе с ним. пока наивно
    local x, y, left, middle, right = tutor_mouse()
    local new_x = x - self.held_point.x
    local new_y = y - self.held_point.y

    local x1 = (new_x + Tile.HITBOX.x1) / 8
    local y1 = (new_y + Tile.HITBOX.y1) / 8
    local x2 = (new_x + Tile.HITBOX.x2) / 8
    local y2 = (new_y + Tile.HITBOX.y2) / 8
    if hand.full() then
        if (BOARD[mget(x1, y1)] or HAND_BORDER[mget(x1, y1)]) and 
           (BOARD[mget(x1, y2)] or HAND_BORDER[mget(x1, y2)]) and 
           (BOARD[mget(x2, y1)] or HAND_BORDER[mget(x2, y1)]) and 
           (BOARD[mget(x2, y2)] or HAND_BORDER[mget(x2, y2)]) then
            self.x = new_x
            self.y = new_y
        end
        return
    end

    if self:is_legal_position(x1, y1, x2, y2) then
        self.x = new_x
        self.y = new_y
    end
end

function TutorTile:what_are_you_doing_with_me()
    if not self.visibility then
        return 'nothing'
    end

    if self.hand_status == 'outside' and self.status ~= 'held' and hand.is_tile_should_go_to_hand(self) then
        if not hand.full() then
            return 'going to hand'
        end
    end

    -- if self.gravity_should_go_to_hand_flag then
    --     return 'going to hand'
    -- end

    local x, y, left, middle, right = tutor_mouse()

    if self.hand_status ~= 'in' and (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
        self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then

        if Settings.QUICK_DRAW_BY_RIGHT_CLICK and Click.right() then
            if not hand.full() then
                return 'going to hand'
            end
            Sound.cant_get_a_card()
        end
    end

    -- if self.status ~= 'held' and hand.is_tile_should_go_to_hand(self) and not hand then
    --     return 'going to hand'
    -- end

    if not left or not (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
        self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then

        if self.status == 'held' and hand.is_tile_should_go_to_hand(self) then
            return 'going to hand'
        end

        if self.hand_status == 'from' then
            self.is_face = false
            self.hand_status = 'outside'
        end

        if (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
            self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then
            return 'scare'
        end
        return 'nothing'
    end

    -- if not left then
    --     if self.status == 'held' and hand.is_tile_should_go_to_hand(self) then
    --         return 'going to hand'
    --     end
    --     return 'scare'
    -- end

    if self.hand_status == 'in' then
        self:set_hand_status('from')
    end

    -- if not hand.full() and Click.double_left() then
    --     return 'going to hand'
    -- end

    -- TODO: БАГ отображения с морганием
    -- комментируем т.к. такой проблемы нет с автокурсором
    -- if self.status ~= 'held' and not Click.left() then
    --     return 'nothing'
    -- end

    self.held_point.x = x - self.x
    self.held_point.y = y - self.y
    return 'hold'
end

TutorTile.__index = TutorTile


Tutorial = {}

Tutorial.pool = {360, 268, 356, 322, 384, 396}

function Tutorial:new()
    local object = {
        pool = {},
        area = {},
        tiles = {},
    }

    shuffle(Tutorial.pool)
    for i = 1, 3 do
        table.insert(object.pool, Tutorial.pool[i])
    end

    setmetatable(object, self)
    return object
end

function Tutorial:init()
    self:_init_area()
    
    for i, t in ipairs(self.pool) do
        for _ = 1, 3 do
            table.insert(self.tiles, TutorTile:new())
        end
    end
end

function Tutorial:_init_area(map_x, map_y)
    if map_x == nil then
        map_x = 60
    end
    if map_y == nil then
        map_y = 51
    end

    local green_squares = {}
    for y = map_y, map_y + 16 do
        for x = map_x, map_x + 29 do
            if mget(x, y) == 236 then
                table.insert(green_squares, {x=x, y=y})
            end
        end
    end
    -- область появления определяем как первый и ПРЕДпоследний пустой зеленый квадрат
    local x = green_squares[1].x
    local y = green_squares[1].y
    self.area.x1 = (x%30)*8
    self.area.y1 = (y%17)*8

    x = green_squares[#green_squares - 1].x
    y = green_squares[#green_squares - 1].y
    self.area.x2 = (x%30)*8
    self.area.y2 = (y%17)*8
end

Tutorial.__index = Tutorial
