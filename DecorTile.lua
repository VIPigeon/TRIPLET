DecorTile = {}
DecorTile.HITBOX = {
    -- обе границы включены
    x1 = 1,
    y1 = 1,
    x2 = 14,
    y2 = 14,
}
DecorTile.STATUS_SPRITE = {
    scared = 32,
    held = 34,
    held_face = 36,
}
DecorTile.back = 96 -- BICYCLE_BACK
DecorTile.face = 98 -- EMPTY FACE
DecorTile.SHADOW = 128

DecorTile.night = {
    face = 100, -- EMPTY FACE
    held_face = 102,
}

function DecorTile:new(x, y, value, flip, rotate, is_back_static, is_reverse)
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
        superposition = {
            value_to_switch = 0,
            t=0,
        },
    }

    setmetatable(object, self)
    return object
end

function DecorTile:update()
    if not self.visibility then
        return
    end

    -- trace(tostring(self)..' hand status = '..self.hand_status)
    -- trace('current x = '..self.x..'\tcurrent y = '..self.y)

    if self.status == 'held' then
        self:move_by_cursor()
    end
end

function DecorTile:set_status(status)
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

function DecorTile:what_are_you_doing_with_me()
    if not self.visibility then
        return 'nothing'
    end

    -- if self.gravity_should_go_to_hand_flag then
    --     return 'going to hand'
    -- end

    local x, y, left, middle, right = mouse()

    -- if self.status ~= 'held' and hand.is_tile_should_go_to_hand(self) and not hand then
    --     return 'going to hand'
    -- end

    if not left or not (self.x + DecorTile.HITBOX.x1 <= x and x <= self.x + DecorTile.HITBOX.x2 and 
        self.y + DecorTile.HITBOX.y1 <= y and y <= self.y + DecorTile.HITBOX.y2) then

        if (self.x + DecorTile.HITBOX.x1 <= x and x <= self.x + DecorTile.HITBOX.x2 and 
            self.y + DecorTile.HITBOX.y1 <= y and y <= self.y + DecorTile.HITBOX.y2) then
            return 'scare'
        end
        return 'nothing'
    end

    -- TODO: БАГ отображения с морганием
    if self.status ~= 'held' and not Click.left() then
        return 'nothing'
    end

    self.held_point.x = x - self.x
    self.held_point.y = y - self.y
    return 'hold'
end

function DecorTile:move_by_cursor()
    -- если тайл удерживается, он двигается вместе с ним. пока наивно
    local x, y, left, middle, right = mouse()
    local new_x = x - self.held_point.x
    local new_y = y - self.held_point.y

    self.x = new_x
    self.y = new_y
end

local night_backup_face = DecorTile.face
local night_backup_held_face = DecorTile.STATUS_SPRITE.held_face

function DecorTile:draw()
    DecorTile.face = night_backup_face
    DecorTile.STATUS_SPRITE.held_face = night_backup_held_face

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

    local COLORKEY = 7
    if self.status == 'scared' then
        spr(is_face and DecorTile.face or DecorTile.back, self.x, self.y, COLORKEY, 1,bf,br,2,2)
        spr(DecorTile.STATUS_SPRITE.scared, self.x, self.y, 11, 1,bf,br,2,2)

        if is_face then
            spr(self.value, self.x, self.y, 12, 1,ff,fr,2,2)
            -- spr(self.value, self.x, self.y, -1, 1,ff,fr,2,2)
        end
    elseif self.status == 'held' then
        -- поднимаем вверх
        local SHIFT = 2
        spr(DecorTile.SHADOW, self.x, self.y, 11, 1,0,0,2,2)
        spr(is_face and DecorTile.face or DecorTile.back, self.x, self.y-SHIFT, COLORKEY, 1,bf,br,2,2)
        if is_face then
            spr(DecorTile.STATUS_SPRITE.held_face, self.x, self.y-SHIFT, COLORKEY, 1,bf,br,2,2)
        else
            spr(DecorTile.STATUS_SPRITE.held, self.x, self.y-SHIFT, COLORKEY, 1,bf,br,2,2)
        end

        if is_face then
            -- if game.current_level.name == 'NIGHT' then
                -- spr(self.value, self.x, self.y-SHIFT, 0, 1,ff,fr,2,2)
            -- else
            spr(self.value, self.x, self.y-SHIFT, 12, 1,ff,fr,2,2)
            -- end
        end

    elseif self.status == 'chill' then
        spr(is_face and DecorTile.face or DecorTile.back, self.x, self.y, COLORKEY, 1,bf,br,2,2)

        if is_face then
            spr(self.value, self.x, self.y, 12, 1,ff,fr,2,2)
        end
    end
    -- DecorTile.face = night_backup_face
    -- DecorTile.STATUS_SPRITE.held_face = night_backup_held_face
end


DecorTile.__index = DecorTile