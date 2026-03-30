
Tile = {}
Tile.SIZE = {
    x = 14,
    y = 14,
}
Tile.STATUS_SPRITE = {
    scared = 32,
    held = 34,
}

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

    if not (self.x <= x and x < self.x + Tile.SIZE.x + 2 and 
        self.y <= y and y < self.y + Tile.SIZE.y + 2) then
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
    if self.is_face then
        spr(self.value, self.x, self.y, 4, 1,0,0,2,2)
    else
        -- ...
    end
    if self.status ~= 'chill' then
        spr(Tile.STATUS_SPRITE[self.status], self.x, self.y, 11, 1,0,0,2,2)
    end
end

Tile.__index = Tile

game = {
    tiles = {Tile:new(40, 40, 256)},
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
