
-- считаем очки во время партии
-- очки начисляются за сбор троек с учетом комбо

ScoreCounter = {}

function ScoreCounter:new(x, y)
    x = x or 21*8 + 2
    y = y or 16*8 + 3
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
        },

        income_animation = {
            value = 0,
            time = 0,
        },
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
    if self.combo > 1 then
        -- print("combo", x+30, y-22)
        -- print("combo", x+34+8, y-22-5)
        local _X = 109
        local _Y = self.y
        -- print("x"..tostring(self.combo), x+40+8, y-11-5)
        -- print("combo! x"..tostring(self.combo), _X, _Y, 13)

        local is_triplet_animation = false
        for _, t in ipairs(game.tiles) do
            if t.triplet_status == 'animation' then
                is_triplet_animation = true
            end
        end

        local effect_color = 15
        local normal_color = 3
        if self.combo < 20 then
            effect_color = 7
            normal_color = 13
        end
        if self.combo < 10 then
            effect_color = 14
            normal_color = 9
        end
        if self.combo < 5 then
            effect_color = 11
            normal_color = 5
        end

        if not is_triplet_animation then
            TextWithOutline.print("x"..tostring(self.combo)..' combo!', game.progress_bar.tile_slot.x + 18, game.progress_bar.tile_slot.y + 5, 2, normal_color, 0, 1, true)
            -- print("x"..tostring(self.combo)..' streak!', game.progress_bar.tile_slot.x + 18, game.progress_bar.tile_slot.y + 5, 11)
        else
            TextWithOutline.print("x"..tostring(self.combo)..' combo!', game.progress_bar.tile_slot.x + 18, game.progress_bar.tile_slot.y + 5, 2, effect_color, 0, 1, true)
        end
    end

    if self.income_animation.time > 0 then
        self.income_animation.time = Basic.tick_timer(self.income_animation.time)
        if self.income_animation.time == 0 then
            self.combo = self.combo + 1
            self.score = self.score + self.income_animation.value
            self.income_animation.value = 0
        end
    end
    local score_color = 14
    if self.income_animation.time > 0 then
        local income_x = x + 36+8
        local income_y = y - 7
        local income_text = '+'..tostring(self.income_animation.value)
        print(income_text, income_x, income_y, score_color)
    end
    
    print("score: "..tostring(self.score), x+8, y, score_color)

    -- print(tostring(self.combo), x+12, y-8)
end

function ScoreCounter:triplet()
    self.income_animation.value = (self.combo+1)*10
    self.income_animation.time = 0.8
    self.income_animation.status = 1
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
end

function ScoreCounter:_drop_control()
    -- local cur_hand_size = hand.size()
    -- if self.prev_hand_size - cur_hand_size == 1 then
    if hand.tile_was_drop() then
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

function ScoreCounter:get_score()
    -- защита от проблем с анимацией
    return self.score + self.income_animation.value
end


ScoreCounter.__index = ScoreCounter
