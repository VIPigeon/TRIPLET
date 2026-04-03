MoveAnimator = {}

-- ОСТОРОЖНО!!!
-- ВАЙБКОД!!!

function MoveAnimator:new(x1, y1, x2, y2, speed)
    local distance = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    local duration = distance / speed
    local object = {
        start_x = x1,
        start_y = y1,

        end_x = x2,
        end_y = y2,

        duration = duration or 1, -- сколько длится движение
        t = 0, -- прогресс [0..1]
    }
    setmetatable(object, self)
    return object
end

-- easing функция (ease-out)
local function easeOutQuad(t)
    return 1 - (1 - t) * (1 - t)
end
local function easeOutCubic(t)
    return 1 - (1 - t)^3
end
local function easeInOut(t)
    local p = 1.8 -- 👈 регулируешь тут

    if t < 0.5 then
        return 0.5 * (2 * t)^p
    else
        return 1 - 0.5 * (2 * (1 - t))^p
    end
end

function MoveAnimator:update(object)
    if self.t >= 1 then return end

    -- увеличиваем прогресс
    self.t = self.t + Time.dt() / self.duration
    if self.t > 1 then self.t = 1 end

    -- применяем easing
    local k = easeInOut(self.t)

    -- интерполяция
    object.x = self.start_x + (self.end_x - self.start_x) * k
    object.y = self.start_y + (self.end_y - self.start_y) * k
end

function MoveAnimator:is_end()
    return self.t >= 1
end

MoveAnimator.__index = MoveAnimator