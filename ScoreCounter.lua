
-- считаем очки во время партии
-- очки начисляются за сбор троек с учетом комбо

ScoreCounter = {}

function ScoreCounter:new(x, y)
    local object = {
        x=x,
        y=y,
        score = 0,
        combo = 0,
        prev_hand_size = 0,

        shake = {
            x = 0,
            y = 0,
            time = 0,
        }
    }
    setmetatable(object, self)
    return object
end

function ScoreCounter:update()
    self.shake.time = Basic.tick_timer(self.shake.time)
    self:_drop_control()
end

function ScoreCounter:draw()
    local x = self.x
    local y = self.y
    if self.shake.time > 0 then
        x = x + math.random(-self.shake.x, self.shake.x)
        y = y - math.random(0, self.shake.y)
    end
    print("score: "..tostring(self.score), x, y)
    -- print(tostring(self.combo), x+12, y-8)
end

function ScoreCounter:triplet()
    self.score = self.score + 15 + self.combo*5
    -- if self.combo < 3 then
    --     self:_shake(0, 1)
    -- elseif self.combo < 5 then
    --     self:_shake(0, 2)
    -- elseif self.combo < 10 then
    --     self:_shake(0, 3)
    -- elseif self.combo < 10 then
    --     self:_shake(1, 3)
    -- elseif self.combo < 15 then
    --     self:_shake(2, 3)
    -- elseif self.combo >= 15 then
    --     self:_shake(3, 3)
    -- end
    self.combo = self.combo + 1
end

function ScoreCounter:_drop_control()
    local cur_hand_size = hand.size()
    if self.prev_hand_size - cur_hand_size == 1 then
        -- комбо прерывается, если мы сбросили тайл
        if self.combo > 0 and self.combo < 3 then
            self:_shake(1, 0)
        elseif self.combo >= 3 and self.combo < 5 then
            self:_shake(2, 0)
        elseif self.combo >= 5 then
            self:_shake(3, 0)
        end
        self.combo = 0
    end
    self.prev_hand_size = cur_hand_size
end

function ScoreCounter:_shake(force_x, force_y)
    self.shake.x = force_x
    self.shake.y = force_y
    self.shake.time = 0.17
end


ScoreCounter.__index = ScoreCounter
