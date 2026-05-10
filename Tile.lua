Tile = {}
Tile.HITBOX = {
    -- обе границы включены
    x1 = 1,
    y1 = 1,
    x2 = 14,
    y2 = 14,
}
Tile.STATUS_SPRITE = {
    scared = 32,
    held = 34,
    held_face = 36,
}
Tile.back = 96 -- BICYCLE_BACK
Tile.face = 98 -- EMPTY FACE
Tile.SHADOW = 128

function Tile:new(x, y, value, flip, rotate, is_back_static, is_reverse)
    flip = flip or 0
    rotate = rotate or 0
    local object = {
        x = x,
        y = y,

        value = value,
        flip = flip,
        rotate = rotate,
        is_back_static = is_back_static,

        is_reverse = is_reverse,  -- рубашку и лицо меняем местами

        status = 'chill',
        -- chill — карту никто не трогает
        -- scared — на карту навели курсор
        -- held — на карте удерживают курсор
        -- для анимации уничтожения:
        -- destroying — карта находится в процессе уничтожения
        -- destroyed — карта уничтожена

        hand_status = 'outside',
        -- outside — тайл лежит вне руки
        -- in — тайл находится в руке
        -- to — игрок отпустил тайл и она должна перейти в руку
        --      нужно было для анимации, сейчас это глупость
        -- from — игрок взял тайл из руки. для обработки is_face

        triplet_status = 'no',
        -- no — не входит в триплет
        -- animation — находится в процессе анимации триплета
        -- done — анимация закончилась и карта просто лежит неприкасаемая

        is_face = false,
        held_point = {
            x = 0,
            y = 0
        },

        move_animator = nil,

        scoring_status = 'no',

        visibility = true,

        -- параметры для кастомных уровней с движением
        gravity_speed = 0,
        slip = {
            -- разделяем для предварительной оптимизации. Извините
            history_x = {}, -- история позиций перемещаемой карты
            history_y = {}, -- история позиций перемещаемой карты

            target_vx = 0,
            target_vy = 0,
            vx = 0,
            vy = 0,
            grip = 2.1, -- скольжение
        },
    }

    setmetatable(object, self)
    return object
end

function Tile:update_gravity()
    -- для уровня GRAVITATION
    if self.triplet_status ~= 'no' then
        return
    end

    if self.status == 'held' or self.hand_status ~= 'outside' then
        self.gravity_speed = 0
        return
    end
    self.gravity_speed = self.gravity_speed + 0.033
    self.y = self.y + self.gravity_speed

    local x1 = (self.x+1)/8
    local y1 = (self.y+1)/8
    local x2 = (self.x+14)/8
    local y2 = (self.y+14)/8
    if not self:is_legal_position(x1, y1, x2, y2) then
        self.y = self.y - self.gravity_speed
        self.gravity_speed = 0
    end
end

function Tile:update_slip()
    -- для уровня SLIP BOARD
    if self.triplet_status ~= 'no' or self.hand_status == 'in' or self.hand_status == 'to' then
        return
    end

    if self.status == 'held' then
        local _HISTORY_SIZE = 10
        while #self.slip.history_x < _HISTORY_SIZE do
            table.insert(self.slip.history_x, self.x)
            table.insert(self.slip.history_y, self.y)
        end
        table.insert(self.slip.history_x, self.x)
        table.insert(self.slip.history_y, self.y)
        table.remove(self.slip.history_x, 1)
        table.remove(self.slip.history_y, 1)
        if Click.release_left() then
            -- игрок отпустил мышку и запустил тайл
            -- trace(self.slip.history_x[_HISTORY_SIZE]..' - '..self.slip.history_x[1])
            self.slip.target_vx = (self.slip.history_x[_HISTORY_SIZE] - self.slip.history_x[1]) / (_HISTORY_SIZE-1)
            -- trace(self.slip.vx)
            self.slip.target_vy = (self.slip.history_y[_HISTORY_SIZE] - self.slip.history_y[1]) / (_HISTORY_SIZE-1)

            self.slip.history_x = {}
            self.slip.history_y = {}
        end
    else
        -- НЕЙРОКОД
        -- коэффициенты "льда"
        local GRIP = 0.33       -- насколько быстро скорость стремится к target_v
                                 -- меньше значение = более скользкая поверхность
        local FRICTION = 0.97   -- очень слабое постоянное затухание
        local STOP_EPS = 0.066    -- порог полной остановки

        -- плавно изменяем текущую скорость в сторону target_v
        self.slip.vx = self.slip.vx + (self.slip.target_vx - self.slip.vx) * GRIP
        self.slip.vy = self.slip.vy + (self.slip.target_vy - self.slip.vy) * GRIP

        -- на льду внешнее воздействие постепенно исчезает,
        -- поэтому и target_v медленно затухает к нулю
        self.slip.target_vx = self.slip.target_vx * FRICTION
        self.slip.target_vy = self.slip.target_vy * FRICTION

        -- обновляем позицию
        local MAX_SPEED = 5
        local d_x = self.slip.vx
        local d_y = self.slip.vy
        if MAX_SPEED^2 < self.slip.vx^2 + self.slip.vy^2 then
            local vec = vector2d.normalize({x=self.slip.vx, y=self.slip.vy})
            d_x = vec.x*MAX_SPEED
            d_y = vec.y*MAX_SPEED
        end

        self.x = self.x + d_x
        self.y = self.y + d_y

        local x1 = (self.x+1)/8
        local y1 = (self.y+1)/8
        local x2 = (self.x+14)/8
        local y2 = (self.y+14)/8
        if not self:is_legal_position(x1, y1, x2, y2) then
            self.x = self.x - d_x
            self.y = self.y - d_y
        end

        -- остановка при очень маленькой скорости
        if math.abs(self.slip.vx) < STOP_EPS and
           math.abs(self.slip.vy) < STOP_EPS and
           math.abs(self.slip.target_vx) < STOP_EPS and
           math.abs(self.slip.target_vy) < STOP_EPS then

            self.slip.vx = 0
            self.slip.vy = 0
            self.slip.target_vx = 0
            self.slip.target_vy = 0
        end
    end
end

function Tile:compare(tile)
    return tile.value == self.value and tile.flip == self.flip and tile.rotate == self.rotate
end

function Tile:in_move_animation()
    return self.hand_status == 'to' or self.triplet_status ~= 'no'
end

function Tile:set_visibility(flag)
    self.visibility = flag
end

function Tile:set_scoring_status(status)
    self.scoring_status = status
end

function Tile:start_score_animation(clock, slot)
    self:set_scoring_status('scoring')
    self.animation_delay = clock

    local v = 88
    if Settings.QUICK then
        v = 121
    end
    self.move_animator = MoveAnimator:new(self.x, self.y, slot.x, slot.y, v)
end

function Tile:update()
    if not self.visibility then
        return
    end

    if game.current_level.name == 'GRAVITATION' then
        self:update_gravity()
    elseif game.current_level.name == 'SLIP BOARD' then
        self:update_slip()
    end

    -- trace(tostring(self)..' hand status = '..self.hand_status)
    -- trace('current x = '..self.x..'\tcurrent y = '..self.y)
    if self.scoring_status == 'scoring' then
        if self.animation_delay > 0 then
            self.animation_delay = Basic.tick_timer(self.animation_delay)
        elseif self.move_animator:is_end() then
            self:set_scoring_status('scored')
        else
            self.move_animator:update(self)
        end
        return
    end

    if self.status == 'held' then
        self:move_by_cursor()
    end
    if self.hand_status == 'to' then
        self.move_animator:update(self)
        if self.move_animator:is_end(self) then
            self:set_hand_status('in')
        end
        -- local nearest_slot_i = hand.add(self)
        -- self.hand_slot_i = nearest_slot_i
        -- self.is_face = true
        -- hand.insert_into_slot(self)
    end
    if self.triplet_status == 'animation' then
        self.move_animator:update(self)
        if self.move_animator:is_end(self) then
            -- trace('TRIPLET')
            self:set_triplet_status('done')
        end
    end
end

function Tile:set_status(status)
    if status == 'held' and self.status ~= 'held' then
        Sound.tile_click()
        if hand.full() then
            Sound.hand_is_full()
        end
    end
    if self.status == 'held' and status ~= 'held' then
        Sound.tile_drop()
    end
    self.status = status
end

function Tile:set_hand_status(hand_status)
    if hand_status == 'to' and self.hand_status ~= 'to' then
        Sound.tile_draw()
    end

    self.hand_status = hand_status
    if hand_status == 'to' then
        local nearest_slot_i = hand.add(self)
        self.hand_slot_i = nearest_slot_i
        self.is_face = true
        local slot = hand.slots[self.hand_slot_i]

        local v = 67
        if Settings.QUICK then
            v = 101
        end
        self.move_animator = MoveAnimator:new(self.x, self.y, slot.x, slot.y, v)

        hand.insert_into_slot(self)
        self.in_hand = true
    elseif hand_status == 'from' then
        hand.remove(self.hand_slot_i)
        self.hand_slot_i = 0  -- испортим на всякий случай
    end
end

-- Tile.TRIPLET_SHIFT = 4
-- Tile.TRIPLET_POINT = {x=4*8-Tile.TRIPLET_SHIFT, y=0}
function Tile:set_triplet_status(triplet_status)
    self.triplet_status = triplet_status
    if triplet_status == 'animation' then
        self:set_status('chill')
        self:set_hand_status('from')
        -- self.move_animator = MoveAnimator:new(self.x, self.y, Tile.TRIPLET_POINT.x + Tile.TRIPLET_SHIFT*game.triplets_count, Tile.TRIPLET_POINT.y, 90)
        local v = 88
        if Settings.QUICK then
            v = 121
        end
        self.move_animator = MoveAnimator:new(self.x, self.y, game.progress_bar.tile_slot.x, game.progress_bar.tile_slot.y, v)
    end
end

function Tile:what_are_you_doing_with_me()
    if not self.visibility then
        return 'nothing'
    end

    if self.hand_status == 'outside' and self.status ~= 'held' and hand.is_tile_should_go_to_hand(self) then
        if not hand.full() then
            return 'going to hand'
        end
    end

    -- if self.gravity_should_go_to_hand_flag then
    --     return 'going to hand'
    -- end

    local x, y, left, middle, right = mouse()

    if self.hand_status ~= 'in' and (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
        self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then

        if Settings.QUICK_DRAW_BY_RIGHT_CLICK and Click.right() then
            if not hand.full() then
                return 'going to hand'
            end
            Sound.cant_get_a_card()
        end
    end

    -- if self.status ~= 'held' and hand.is_tile_should_go_to_hand(self) and not hand then
    --     return 'going to hand'
    -- end

    if not left or not (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
        self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then

        if self.status == 'held' and hand.is_tile_should_go_to_hand(self) then
            return 'going to hand'
        end

        if self.hand_status == 'from' then
            self.is_face = false
            self.hand_status = 'outside'
        end

        if (self.x + Tile.HITBOX.x1 <= x and x <= self.x + Tile.HITBOX.x2 and 
            self.y + Tile.HITBOX.y1 <= y and y <= self.y + Tile.HITBOX.y2) then
            return 'scare'
        end
        return 'nothing'
    end

    -- if not left then
    --     if self.status == 'held' and hand.is_tile_should_go_to_hand(self) then
    --         return 'going to hand'
    --     end
    --     return 'scare'
    -- end

    if self.hand_status == 'in' then
        self:set_hand_status('from')
    end

    -- if not hand.full() and Click.double_left() then
    --     return 'going to hand'
    -- end

    -- TODO: БАГ отображения с морганием
    if self.status ~= 'held' and not Click.left() then
        return 'nothing'
    end

    self.held_point.x = x - self.x
    self.held_point.y = y - self.y
    return 'hold'
end

function Tile:is_legal_position(x1, y1, x2, y2)
    if hand.full() then
        return (BOARD[mget(x1, y1)] or HAND_BORDER[mget(x1, y1)]) and 
       (BOARD[mget(x1, y2)] or HAND_BORDER[mget(x1, y2)]) and 
       (BOARD[mget(x2, y1)] or HAND_BORDER[mget(x2, y1)]) and 
       (BOARD[mget(x2, y2)] or HAND_BORDER[mget(x2, y2)])
    end

    return (BOARD[mget(x1, y1)] or HAND[mget(x1, y1)] or HAND_BORDER[mget(x1, y1)]) and 
       (BOARD[mget(x1, y2)] or HAND[mget(x1, y2)] or HAND_BORDER[mget(x1, y2)]) and 
       (BOARD[mget(x2, y1)] or HAND[mget(x2, y1)] or HAND_BORDER[mget(x2, y1)]) and 
       (BOARD[mget(x2, y2)] or HAND[mget(x2, y2)] or HAND_BORDER[mget(x2, y2)])
end

function Tile:move_by_cursor()
    -- если тайл удерживается, он двигается вместе с ним. пока наивно
    local x, y, left, middle, right = mouse()
    local new_x = x - self.held_point.x
    local new_y = y - self.held_point.y

    local x1 = (new_x + Tile.HITBOX.x1) / 8
    local y1 = (new_y + Tile.HITBOX.y1) / 8
    local x2 = (new_x + Tile.HITBOX.x2) / 8
    local y2 = (new_y + Tile.HITBOX.y2) / 8
    if hand.full() then
        if (BOARD[mget(x1, y1)] or HAND_BORDER[mget(x1, y1)]) and 
           (BOARD[mget(x1, y2)] or HAND_BORDER[mget(x1, y2)]) and 
           (BOARD[mget(x2, y1)] or HAND_BORDER[mget(x2, y1)]) and 
           (BOARD[mget(x2, y2)] or HAND_BORDER[mget(x2, y2)]) then
            self.x = new_x
            self.y = new_y
        end
        return
    end

    if self:is_legal_position(x1, y1, x2, y2) then
        self.x = new_x
        self.y = new_y
    end
end

function Tile:draw()
    local is_face = self.is_face
    if self.is_reverse then
        is_face = not is_face
    end


    if not self.visibility then
        return
    end

    local ff = self.flip
    local fr = self.rotate
    local bf = ff
    local br = fr
    if self.is_back_static then
        bf = 0
        br = 0
    end

    if self.status == 'scared' then
        spr(is_face and Tile.face or Tile.back, self.x, self.y, 0, 1,bf,br,2,2)
        spr(Tile.STATUS_SPRITE.scared, self.x, self.y, 11, 1,bf,br,2,2)

        if is_face then
            spr(self.value, self.x, self.y, 15, 1,ff,fr,2,2)
        end
    elseif self.status == 'held' then
        -- поднимаем вверх
        local SHIFT = 2
        spr(Tile.SHADOW, self.x, self.y, 11, 1,0,0,2,2)
        spr(is_face and Tile.face or Tile.back, self.x, self.y-SHIFT, 0, 1,bf,br,2,2)
        if is_face then
            spr(Tile.STATUS_SPRITE.held_face, self.x, self.y-SHIFT, 0, 1,bf,br,2,2)
        else
            spr(Tile.STATUS_SPRITE.held, self.x, self.y-SHIFT, 0, 1,bf,br,2,2)
        end

        if is_face then
            spr(self.value, self.x, self.y-SHIFT, 15, 1,ff,fr,2,2)
        end

    elseif self.status == 'chill' then
        spr(is_face and Tile.face or Tile.back, self.x, self.y, 0, 1,bf,br,2,2)

        if is_face then
            spr(self.value, self.x, self.y, 15, 1,ff,fr,2,2)
        end
    end    
end

function Tile:is_scored()
    return self.scoring_status == 'scored'
end


Tile.__index = Tile