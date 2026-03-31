Tile = {}
Tile.HITBOX = {
    -- обе границы включены
    x1 = 1,
    y1 = 1,
    x2 = 14,
    y2 = 14,
}
Tile.STATUS_SPRITE = {
    scared = 32,
    held = 34,
    held_face = 36,
}
Tile.back = 96 -- BICYCLE_BACK
Tile.face = 98 -- EMPTY FACE
Tile.SHADOW = 128
function Tile:new(x, y, value)
    local object = {
        x = x,
        y = y,
        value = value,
        status = 'chill',
        is_face = false,  -- будет использоваться в туториале
        held_point = {
            x = 0,
            y = 0
        },
        -- возможные status:
        -- chill — обычное состояние
        -- scared — на тайл навели курсор
        -- held — тайл удерживают и перемещают курсором
    }

    setmetatable(object, self)
    return object
end

function Tile:update()
    if self.status == 'held' then
        self:move_by_cursor()
    end
end

function Tile:set_status(status)
    self.status = status
end

function Tile:what_are_you_doing_with_me()
    local x, y, left, middle, right = mouse()

    if not (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
        self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then
        return 'nothing'
    end

    if not left then
        return 'scare'
    end

    self.held_point.x = x - self.x
    self.held_point.y = y - self.y
    return 'hold'
end

function Tile:move_by_cursor()
    -- если тайл удерживается, он двигается вместе с ним. пока наивно
    local x, y, left, middle, right = mouse()
    local new_x = x - self.held_point.x
    local new_y = y - self.held_point.y

    local x1 = (new_x + Tile.HITBOX.x1) / 8
    local y1 = (new_y + Tile.HITBOX.y1) / 8
    local x2 = (new_x + Tile.HITBOX.x2) / 8
    local y2 = (new_y + Tile.HITBOX.y2) / 8
    if (BOARD[mget(x1, y1)] or HAND[mget(x1, y1)] or HAND_BORDER[mget(x1, y1)]) and 
       (BOARD[mget(x1, y2)] or HAND[mget(x1, y2)] or HAND_BORDER[mget(x1, y2)]) and 
       (BOARD[mget(x2, y1)] or HAND[mget(x2, y1)] or HAND_BORDER[mget(x2, y1)]) and 
       (BOARD[mget(x2, y2)] or HAND[mget(x2, y2)] or HAND_BORDER[mget(x2, y2)]) then
        self.x = new_x
        self.y = new_y
    end
end

function Tile:draw()
    if self.status == 'scared' then
        spr(self.is_face and Tile.face or Tile.back, self.x, self.y, 0, 1,0,0,2,2)
        spr(Tile.STATUS_SPRITE.scared, self.x, self.y, 11, 1,0,0,2,2)

        if self.is_face then
            spr(self.value, self.x, self.y, 15, 1,0,0,2,2)
        end
    elseif self.status == 'held' then
        -- поднимаем вверх
        local SHIFT = 2
        spr(Tile.SHADOW, self.x, self.y, 11, 1,0,0,2,2)
        spr(self.is_face and Tile.face or Tile.back, self.x, self.y-SHIFT, 0, 1,0,0,2,2)
        if self.is_face then
            spr(Tile.STATUS_SPRITE.held_face, self.x, self.y-SHIFT, 0, 1,0,0,2,2)
        else
            spr(Tile.STATUS_SPRITE.held, self.x, self.y-SHIFT, 0, 1,0,0,2,2)
        end

        if self.is_face then
            spr(self.value, self.x, self.y-SHIFT, 15, 1,0,0,2,2)
        end

    elseif self.status == 'chill' then
        spr(self.is_face and Tile.face or Tile.back, self.x, self.y, 0, 1,0,0,2,2)

        if self.is_face then
            spr(self.value, self.x, self.y, 15, 1,0,0,2,2)
        end
    end    
end

Tile.__index = Tile