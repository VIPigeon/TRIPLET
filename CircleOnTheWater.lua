CircleOnTheWater = {}

function CircleOnTheWater:new(x, y, color)
    local object = {
        x = x,
        y = y,
        V = 0.25,
        r = 3.1,
        color = color,
    }
    setmetatable(object, self)
    return object
end

function CircleOnTheWater:update()
    -- self.r = self.r + self.V
    self.r = math.max(0, self.r - self.V)
end

function CircleOnTheWater:draw()
    -- circb(self.x, self.y, self.r, self.color)
    circ(self.x, self.y, self.r, self.color)
end

CircleOnTheWater.__index = CircleOnTheWater
