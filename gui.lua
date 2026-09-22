
--[[
размер кнопки автоматически подстраивается под текст кнопки
вся гуишная логика будет лежать в этом файле, для удобства

ОСТОРОЖНО!!!
ПРИ СОЗДАНИИ КНОПКИ ОНА СОЗДАЕТСЯ НЕВИДИМОЙ
Чтобы включить кнопку, нужно еще вызвать :set_visibility(true)
]]


Button = {}

function Button:new(x, y, text, size_x, size_y, colors, scale)
    colors = colors or {text=4, chill=10, scared=15, pressed=14, shadow=4}
    -- определяем хитбокс по тексту
    scale = scale or 1
    size_x = size_x or #text * 6 * scale
    size_y = size_y or 7 * scale
    local object = {
        x1=x,
        y1=y,
        x2=x + size_x,
        y2=y + size_y,
        text=text,
        status='chill',
        color=colors,
        -- chill — никто не трогает
        -- scared — на кнопку навели мышку
        -- pressed — на кнопку нажали
        scale=scale,
    }
    setmetatable(object, self)
    return object
end

function Button:update()
    self.prev_status = self.status
    local x, y, left, middle, right = mouse()

    if self.x1 <= x and x <= self.x2 and self.y1 <= y and y <= self.y2 then
        if left then
            if self.status ~= 'pressed' then
                Sound.button_interact('press')
            end
            self.status = 'pressed'
        else
            if self.status == 'chill' then
                Sound.button_interact('scare')
            elseif self.status == 'pressed' then
                Sound.button_interact('release')
            end
            self.status = 'scared'
        end
        return
    end
    self.status = 'chill'
end

function Button:draw()
    local s = self.scale
    -- shadow
    rect(self.x1-s, self.y1 +s, self.x2-self.x1+s*3, self.y2-self.y1, self.color.shadow)
    rect(self.x1, self.y1-s +s, self.x2-self.x1+s, self.y2-self.y1+s*2, self.color.shadow)
    if self.status == 'chill' or self.status == 'scared' then
        rect(self.x1-s, self.y1, self.x2-self.x1+s*3, self.y2-self.y1, self.color[self.status])
        rect(self.x1, self.y1-s, self.x2-self.x1+s, self.y2-self.y1+2*s, self.color[self.status])
        print(self.text, self.x1 + s, self.y1 + s, self.color.text, false, s)
    else  -- pressed
        rect(self.x1-s, self.y1 +s, self.x2-self.x1+3*s, self.y2-self.y1, self.color.pressed)
        rect(self.x1, self.y1-s +s, self.x2-self.x1+s, self.y2-self.y1+2*s, self.color.pressed)
        print(self.text, self.x1+s, self.y1+s+s, self.color.text, false, s)
    end
end

function Button:set_visibility(flag)
    self.visibility = flag
end

function Button:is_pressed()
    return self.prev_status == 'pressed' and self.status == 'scared'
end

Button.__index = Button

ToggleButton = table.copy(Button)

-- копипаст > наследования
function ToggleButton:new(x, y, text_on, text_off, init_state, text_right, size_x, size_y, colors)
    text_right = text_right or ''  -- текста справа от кнопки
    colors = colors or {
        text = {[true]=4, [false]=1},
        chill = {[true]=15, [false]=4},
        scared= {[true]=10, [false]=9},
        -- pressed={[true]=3, [false]=11},
        pressed={[true]=14, [false]=14},
        shadow = {[true]=4, [false]=1},
    }
    -- определяем хитбокс по тексту
    size_x = size_x or math.max(#text_on, #text_off) * 6
    size_y = size_y or 7
    local object = {
        x1=x,
        y1=y,
        x2=x + size_x,
        y2=y + size_y,
        text={[true]=text_on, [false]=text_off},
        status='chill',
        color=colors,
        is_on=init_state,
        text_right = text_right,

        is_toggle = true, -- для идентификации
        -- chill — никто не трогает
        -- scared — на кнопку навели мышку
        -- pressed — на кнопку нажали
    }
    setmetatable(object, self)
    return object
end

function ToggleButton:draw()
    -- shadow
    rect(self.x1-1, self.y1-1 +1, self.x2-self.x1 +3, self.y2-self.y1 +2, self.color.shadow[self.is_on])
    if self.status == 'chill' then
        rect(self.x1-1, self.y1-1, self.x2-self.x1 +3, self.y2-self.y1 +2, self.color.chill[self.is_on])
        print(self.text[self.is_on], self.x1+1, self.y1+1, self.color.text[self.is_on])
    elseif self.status == 'scared' then
        rect(self.x1-1, self.y1-1, self.x2-self.x1 +3, self.y2-self.y1 +2, self.color.scared[self.is_on])
        print(self.text[self.is_on], self.x1+1, self.y1+1, self.color.text[self.is_on])
    else  -- pressed
        rect(self.x1-1, self.y1-1 +1, self.x2-self.x1 +3, self.y2-self.y1 +2, self.color.pressed[self.is_on])
        print(self.text[self.is_on], self.x1+1, self.y1+1 +1, self.color.text[self.is_on])
    end

    local x = self.x2 + 4
    local y = self.y1 + 1
    -- эта обводка просто имба. по-хорошему в отдельную фукнцию вынести
    print(self.text_right, x+1, y+1, self.color.shadow[self.is_on])
    print(self.text_right, x-1, y-1, self.color.shadow[self.is_on])
    print(self.text_right, x+1, y-1, self.color.shadow[self.is_on])
    print(self.text_right, x-1, y+1, self.color.shadow[self.is_on])
    print(self.text_right, x, y+1, self.color.shadow[self.is_on])
    print(self.text_right, x, y-1, self.color.shadow[self.is_on])
    print(self.text_right, x-1, y, self.color.shadow[self.is_on])
    print(self.text_right, x+1, y, self.color.shadow[self.is_on])
    print(self.text_right, x, y, self.color.scared[self.is_on])
end

ToggleButton.__index = ToggleButton


SpriteButton = table.copy(Button)
function SpriteButton:new(x, y, sprites, size_x, size_y, scale)
    scale = scale or 1
    -- определяем хитбокс по тексту
    local object = {
        -- вбиваем координаты хитбокса. граница кнопки не включена
        x1=x+1,
        y1=y+1,
        x2=x + size_x -2,
        y2=y + size_y -2,
        sprite=sprites,
        is_on=true,

        status='chill',
        -- chill — никто не трогает
        -- scared — на кнопку навели мышку
        -- pressed — на кнопку нажали

        scale = scale,
    }
    setmetatable(object, self)
    return object
end

function SpriteButton:draw(colorkey)
    colorkey = colorkey or 0
    -- я не уверен что эти формулы корректны, нужно тестить
    local width = (self.x2-self.x1+2+7)/8 / self.scale
    local height = (self.y2-self.y1+2+7)/8 / self.scale
    spr(self.sprite[self.status], self.x1-1, self.y1-1, colorkey, self.scale,0,0, width,height)
end

SpriteButton.__index = SpriteButton


AdviceButton = table.copy(SpriteButton)
-- имеет поле .advice

AdviceButton.window_box = {x1=3, y1=4*8+3, x2=20*8, y2=9*8+5}
AdviceButton.box_color = 10
AdviceButton.shadow_color = 4
AdviceButton.text_color = 4

function AdviceButton:set_window_status(window_status)
    -- СПИСОК СТАТУСОВ
    -- button. начальный статус, задается в MapDecor.init()
    -- button_to_window
    -- window
    -- window_to_button
    if window_status == 'button_to_window' then
        -- local x = self.x1
        -- local y = self.y1
        self.animator = StretchingAnimator:new(
            {
                x1=self.x1,
                y1=self.y1,
                x2=self.x2,
                y2=self.y2,
            },
            AdviceButton.window_box)
    elseif window_status == 'window_to_button' then
        self.animator.is_reverse = true
    end

    self.window_status = window_status
end

function AdviceButton:update()
    if self.window_status == 'button' then
    -- Button update
        self.prev_status = self.status
        local x, y, left, middle, right = mouse()

        if self.x1 <= x and x <= self.x2 and self.y1 <= y and y <= self.y2 then
            if left then
                if self.status ~= 'pressed' then
                    Sound.button_interact('press')
                end
                self.status = 'pressed'
            else
                if self.status == 'chill' then
                    Sound.button_interact('scare')
                elseif self.status == 'pressed' then
                    Sound.button_interact('release')
                end
                self.status = 'scared'
            end
            return
        end
        self.status = 'chill'
    --
    end

    if self.window_status == 'button_to_window' then
        self.animator:update()
        -- trace(self.animator.current_box.x1)
        if self.animator:is_end() then
            self:set_window_status('window')
            -- trace(self.animator.current_box.x1)
        end
    elseif self.window_status == 'window' then
        if Click.left() or Click.right() then
            self:set_window_status('window_to_button')
            -- trace(self.animator.current_box.x1)
        end
    elseif self.window_status == 'window_to_button' then
        self.animator:update()
        if self.animator:is_end() then
            self:set_window_status('button')
        end
    end
end

function AdviceButton:draw_box(box)
    rect(box.x1+1, box.y1, box.x2-box.x1-2, box.y2-box.y1+1, AdviceButton.shadow_color)
    rect(box.x1, box.y1+1, box.x2-box.x1, box.y2-box.y1-2+1, AdviceButton.shadow_color)

    rect(box.x1+1, box.y1, box.x2-box.x1-2, box.y2-box.y1, AdviceButton.box_color)
    rect(box.x1, box.y1+1, box.x2-box.x1, box.y2-box.y1-2, AdviceButton.box_color)
end

function AdviceButton:draw(colorkey)
    colorkey = colorkey or 0

    if self.window_status == 'button' then
        -- я не уверен что эти формулы корректны, нужно тестить
        local width = (self.x2-self.x1+2+7)/8 / self.scale
        local height = (self.y2-self.y1+2+7)/8 / self.scale
        spr(self.sprite[self.status], self.x1-1, self.y1-1, colorkey, self.scale,0,0, width,height)
    elseif self.window_status == 'button_to_window' or self.window_status == 'window_to_button' then
        local box = self.animator.current_box
        self:draw_box(box)
    elseif self.window_status == 'window' then
        local box = self.animator.current_box
        self:draw_box(box)
        -- rect(box.x1, box.y1, box.x2-box.x1, box.y2-box.y1+1, AdviceButton.shadow_color)
        -- rect(box.x1, box.y1, box.x2-box.x1, box.y2-box.y1, AdviceButton.box_color)
        local y = box.y1 + 5
        local dy = 9
        -- print(tostring(self.id)..'. '..self.name, box.x1 + 6, y, 9)
        -- print(self.name, box.x1 + 6, y, 9, false, 2)
        -- y = y + dy
        for _, line in ipairs(self.advice) do
            print(line, box.x1 + 6, y, AdviceButton.text_color)
            y = y + dy
        end
    end
end

AdviceButton.__index = AdviceButton



AnimalButton = {}

function AnimalButton:new(id, x, y, is_explored)
    local object = {
        id = id,
        x = x,
        y = y,
        is_explored = is_explored,
        status = 'chill',
        -- chill — обычное состояние
        -- scared — навели курсор
        -- pressed — на карточку нажали
        -- active — карточку сейчас читают
    }
    setmetatable(object, self)
    return object
end

function AnimalButton:draw()
end

AnimalButton.__index = AnimalButton