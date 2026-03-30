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
}
Tile.back = 96 -- BICYCLE_BACK
Tile.SHADOW = 128
function Tile:new(x, y, value)
    local object = {
        x = x,
        y = y,
        value = value,
        status = 'chill',
        is_face = true,
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
    x, y, left, middle, right = mouse()

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
    x, y, left, middle, right = mouse()
    self.x = x - self.held_point.x
    self.y = y - self.held_point.y
end

function Tile:draw()
    if self.status == 'scared' then
        spr(Tile.back, self.x, self.y, 0, 1,0,0,2,2)
        spr(Tile.STATUS_SPRITE.scared, self.x, self.y, 11, 1,0,0,2,2)
    elseif self.status == 'held' then
        -- поднимаем вверх
        spr(Tile.back, self.x, self.y-1, 0, 1,0,0,2,2)
        spr(Tile.STATUS_SPRITE.held, self.x, self.y-1, 0, 1,0,0,2,2)
        spr(Tile.SHADOW, self.x, self.y, 11, 1,0,0,2,2)
    elseif self.status == 'chill' then
        spr(Tile.back, self.x, self.y, 0, 1,0,0,2,2)
    end
end

Tile.__index = Tile