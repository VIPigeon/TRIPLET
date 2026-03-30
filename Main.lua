
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
    x, y, left, middle, right = mouse()

    if self.status == 'held' and left then
        self.x = x - self.held_point.x
        self.y = y - self.held_point.y
        return
    end

    if not (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
        self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then
        self.status = 'chill'
        return
    end

    if not left then
        self.status = 'scared'
        return
    end

    self.status = 'held'
    self.held_point.x = x - self.x
    self.held_point.y = y - self.y
end

function Tile:draw()
    if self.status == 'scared' then
        spr(Tile.back, self.x, self.y, 0, 1,0,0,2,2)
        spr(Tile.STATUS_SPRITE.scared, self.x, self.y, 11, 1,0,0,2,2)
    elseif self.status == 'held' then
        -- поднимаем вверх
        spr(Tile.back, self.x, self.y-1, 0, 1,0,0,2,2)
        spr(Tile.STATUS_SPRITE.held, self.x, self.y-1, 0, 1,0,0,2,2)
        spr(Tile.SHADOW, self.x, self.y, 0, 1,0,0,2,2)
    elseif self.status == 'chill' then
        spr(Tile.back, self.x, self.y, 0, 1,0,0,2,2)
    end
end

Tile.__index = Tile

game = {
    tiles = {
        Tile:new(40, 40, 256),
        -- Tile:new(41, 41, 256),
    },
}

function game.update()
    for _, tile in ipairs(game.tiles) do
        tile:update()
    end
    game.draw()
end


function game.draw()
    cls(4)
    for _, tile in ipairs(game.tiles) do
        tile:draw()
    end
end

-- game.init()

-- TIC-80 🤖 обязывает нас объявлять функцию TIC, которую он будет
-- вызывать каждый кадр.
function TIC()
    game.update()
end
