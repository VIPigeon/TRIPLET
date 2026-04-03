
MoveAnimator = {}

function MoveAnimator:new(x1, y1, x2, y2, v)
    -- переводим скорость в скорость по x и по y
    -- trace(x1..' '..y1..' '..x2..' '..y2)
    local c = vector2d.normalize( {x=x2-x1, y=y2-y1} )
    local v_x = c.x * v
    local v_y = c.y * v
    -- 🤡 движение расчитывается по кадрам!

    local object = {
        -- start_x = x1,
        -- start_y = y1,
        -- конечная точка
        end_x = x2,
        end_y = y2,

        v_x = v_x,
        v_y = v_y,
    }
    setmetatable(object, self)
    return object
end

function MoveAnimator:update(object)
    -- какую скорость не ставь, линейное движение остается линейным и ощущается топорно
    -- trace(math.abs(object.x - self.end_x))
    if (self.v_x > 0 and self.end_x <= object.x) or
        (self.v_x < 0 and self.end_x >= object.x) then
        object.x = self.end_x
    else
        object.x = object.x + self.v_x
    end

    if (self.v_y > 0 and self.end_y <= object.y) or
        (self.v_y < 0 and self.end_y >= object.y) then
        object.y = self.end_y
    else
        object.y = object.y + self.v_y
    end
end

function MoveAnimator:is_end(object)
    return object.x == self.end_x and object.y == self.end_y
end

MoveAnimator.__index = MoveAnimator
