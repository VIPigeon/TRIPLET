
MoveAnimator = {}

function MoveAnimator:new(x1, y1, x2, y2, v)
    -- переводим скорость в скорость по x и по y
    local c = {x=x2-x1, y=y2-y1}
    local a = {x=x2-x1, y=0}
    local b = {x=0, y=y2-y1}
    local v_x = vector2d.dot(c, a) / vector2d.abs(a)
    local v_y = vector2d.dot(c, b) / vector2d.abs(b)
    -- 🤡 движение расчитывается по кадрам!

    local object = {
        -- текущая точка
        x=x1,
        y=y1,
        -- конечная точка
        end_x = x2,
        end_y = y2,

        v_x = v_x,
        v_y = v_y,
    }
    setmetatable(object, self)
    return object
end

function MoveAnimator:update()
    if math.abs(self.x - self.end_x) <= self.v_x then
        self.x = self.end_x
    else
        self.x = self.x + self.v_x
    end

    if math.abs(self.y - self.end_y) <= self.v_y then
        self.y = self.end_y
    else
        self.y = self.y + self.v_y
    end
end

function MoveAnimator:is_end()
    return self.x == self.end_x and self.y == self.end_y
end

MoveAnimator.__index = MoveAnimator
