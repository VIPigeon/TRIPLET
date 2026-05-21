CircleOnTheWater = {}

function CircleOnTheWater:new(x, y, color)
    local object = {
        x = x,
        y = y,
        V = 1,
        r = 0,
        color = color,
    }
    setmetatable(object, self)
    return object
end

function CircleOnTheWater:update()
    self.r = self.r + self.V
end

function CircleOnTheWater:draw()
    circb(self.x, self.y, self.r, self.color)
end

CircleOnTheWater.__index = CircleOnTheWater
