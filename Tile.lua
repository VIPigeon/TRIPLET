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

function Tile:new(x, y, value)
    local object = {
        x = x,
        y = y,
        value = value,
        status = 'chill',
        -- chill — карту никто не трогает
        -- scared — на карту навели курсор
        -- held — на карте удерживают курсор

        hand_status = 'outside',
        -- outside — тайл лежит вне руки
        -- in — тайл находится в руке
        -- to — игрок отпустил тайл и она должна перейти в руку. ДЛЯ АНИМАЦИИ
        -- from — игрок взял тайл из руки. для обработки is_face

        triplet_status = 'no',
        -- no — не входит в триплет
        -- animation — находится в процессе анимации триплета
        -- done — находится в процессе уничтожения

        is_face = false,
        held_point = {
            x = 0,
            y = 0
        },

        move_animator = nil,
    }

    setmetatable(object, self)
    return object
end

function Tile:update()
    if self.status == 'held' then
        self:move_by_cursor()
    end
    if self.hand_status == 'to' then
        self.is_face = true

        self.move_animator:update()
        self.x = self.move_animator.x
        self.y = self.move_animator.y

        if self.move_animator:is_end() then
            self:set_hand_status('in')
            self.in_hand = true
            -- local nearest_slot_i = hand.add(self)
            -- self.hand_slot_i = nearest_slot_i
            hand.insert_into_slot(self)
        end

        -- в момент попадания тайла в руку может собраться триплет
        if hand.is_there_a_triplet() then
            trace('TRIPLET')
        end
    end
end

function Tile:set_status(status)
    self.status = status
end

function Tile:set_hand_status(hand_status)
    self.hand_status = hand_status
    if hand_status == 'to' then
        local nearest_slot_i = hand.add(self)
        self.hand_slot_i = nearest_slot_i
        local slot = hand.slots[nearest_slot_i]
        self.move_animator = MoveAnimator:new(self.x, self.y, slot.x, slot.y, 0.5)
    end
end

function Tile:what_are_you_doing_with_me()
    local x, y, left, middle, right = mouse()

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
        hand.remove(self.hand_slot_i)
        self.hand_slot_i = 0  -- испортим на всякий случай
    end

    self.held_point.x = x - self.x
    self.held_point.y = y - self.y
    return 'hold'
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
        if (BOARD[mget(x1, y1)]) and 
           (BOARD[mget(x1, y2)]) and 
           (BOARD[mget(x2, y1)]) and 
           (BOARD[mget(x2, y2)]) then
            self.x = new_x
            self.y = new_y
        end
        return
    end
    if (BOARD[mget(x1, y1)] or HAND[mget(x1, y1)] or HAND_BORDER[mget(x1, y1)]) and 
       (BOARD[mget(x1, y2)] or HAND[mget(x1, y2)] or HAND_BORDER[mget(x1, y2)]) and 
       (BOARD[mget(x2, y1)] or HAND[mget(x2, y1)] or HAND_BORDER[mget(x2, y1)]) and 
       (BOARD[mget(x2, y2)] or HAND[mget(x2, y2)] or HAND_BORDER[mget(x2, y2)]) then
        self.x = new_x
        self.y = new_y
    end
end

function Tile:draw()
    if self.status == 'scared' then
        spr(self.is_face and Tile.face or Tile.back, self.x, self.y, 0, 1,0,0,2,2)
        spr(Tile.STATUS_SPRITE.scared, self.x, self.y, 11, 1,0,0,2,2)

        if self.is_face then
            spr(self.value, self.x, self.y, 15, 1,0,0,2,2)
        end
    elseif self.status == 'held' then
        -- поднимаем вверх
        local SHIFT = 2
        spr(Tile.SHADOW, self.x, self.y, 11, 1,0,0,2,2)
        spr(self.is_face and Tile.face or Tile.back, self.x, self.y-SHIFT, 0, 1,0,0,2,2)
        if self.is_face then
            spr(Tile.STATUS_SPRITE.held_face, self.x, self.y-SHIFT, 0, 1,0,0,2,2)
        else
            spr(Tile.STATUS_SPRITE.held, self.x, self.y-SHIFT, 0, 1,0,0,2,2)
        end

        if self.is_face then
            spr(self.value, self.x, self.y-SHIFT, 15, 1,0,0,2,2)
        end

    elseif self.status == 'chill' then
        spr(self.is_face and Tile.face or Tile.back, self.x, self.y, 0, 1,0,0,2,2)

        if self.is_face then
            spr(self.value, self.x, self.y, 15, 1,0,0,2,2)
        end
    end    
end

Tile.__index = Tile