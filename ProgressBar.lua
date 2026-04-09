
-- прогресс бар, куда выкладываются тайлы во время сессии
ProgressBar = {}

function ProgressBar:new(x, y, count_tiles, colors)
    colors = colors or {body=0, around=5}
    local n = count_tiles
    local TRIPLET_SHIFT = 4
    local TILE_SIZE = 14
    local length = TRIPLET_SHIFT*(n-1) + TILE_SIZE

    local object = {
        x = x,
        y = y,
        color = colors,
        length = length,
        n = n,
        shift = TRIPLET_SHIFT,
        tile_slot = {x=x-1 - TRIPLET_SHIFT, y=y-1},
    }
    setmetatable(object, self)
    return object
end

function ProgressBar:add()
    self.n = self.n - 1
    self.tile_slot.x = self.tile_slot.x + self.shift
end

function ProgressBar:full()
    return self.n == 0
end

function ProgressBar:draw()
    local function draw_bar(x, y, length, height, color)
        rect(x, y+2, length, height-4, color)
        rect(x+1, y+1, length-2, height-2, color)
        rect(x+2, y, length-4, height, color)
    end
    local TILE_SIZE = 14

    -- обводка через смещение
    draw_bar(self.x+2, self.y+1, self.length-2, TILE_SIZE - 2, self.color.around)
    draw_bar(self.x+1, self.y+2, self.length-2, TILE_SIZE - 2, self.color.around)
    draw_bar(self.x+1, self.y, self.length-2, TILE_SIZE - 2, self.color.around)
    draw_bar(self.x, self.y+1, self.length-2, TILE_SIZE - 2, self.color.around)
    -- draw_bar(self.x, self.y, self.length, TILE_SIZE, self.color.around)

    draw_bar(self.x+1, self.y+1, self.length-2, TILE_SIZE - 2, self.color.body)
end

ProgressBar.__index = ProgressBar
