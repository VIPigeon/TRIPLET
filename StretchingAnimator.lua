
StretchingAnimator = {}

function StretchingAnimator:new(init_box, target_box)
    local object = {
        init_box = init_box,  -- для ревёрса
        current_box = table.copy(init_box),
        target_box = target_box,
        v = 20,
        is_reverse = false,
    }

    setmetatable(object, self)
    return object
end

function StretchingAnimator:update()
    if self.is_reverse then
        self:reverse_update()
        return
    end

    if self.current_box.x1 > self.target_box.x1 then
        self.current_box.x1 = math.max(self.current_box.x1 - self.v, self.target_box.x1)
    end
    if self.current_box.x2 < self.target_box.x2 then
        self.current_box.x2 = math.min(self.current_box.x2 + self.v, self.target_box.x2)
    end

    if self.current_box.y1 > self.target_box.y1 then
        self.current_box.y1 = math.max(self.current_box.y1 - self.v/2, self.target_box.y1)
    end
    if self.current_box.y2 < self.target_box.y2 then
        self.current_box.y2 = math.min(self.current_box.y2 + self.v/2, self.target_box.y2)
    end
end

function StretchingAnimator:reverse_update()
    if self.current_box.x1 < self.init_box.x1 then
        self.current_box.x1 = math.min(self.current_box.x1 + self.v, self.init_box.x1)
    end
    if self.current_box.x2 > self.init_box.x2 then
        self.current_box.x2 = math.max(self.current_box.x2 - self.v, self.init_box.x2)
    end

    if self.current_box.y1 < self.init_box.y1 then
        self.current_box.y1 = math.min(self.current_box.y1 + self.v/2, self.init_box.y1)
    end
    if self.current_box.y2 > self.init_box.y2 then
        self.current_box.y2 = math.max(self.current_box.y2 - self.v/2, self.init_box.y2)
    end
end

function StretchingAnimator:is_end()
    if self.is_reverse then 
        return table.equals(self.current_box, self.init_box)
    end
    return table.equals(self.current_box, self.target_box)
end


StretchingAnimator.__index = StretchingAnimator
