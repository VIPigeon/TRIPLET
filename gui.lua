
--[[
размер кнопки автоматически подстраивается под текст кнопки
вся гуишная логика будет лежать в этом файле, для удобства

ОСТОРОЖНО!!!
ПРИ СОЗДАНИИ КНОПКИ ОНА СОЗДАЕТСЯ НЕВИДИМОЙ
Чтобы включить кнопку, нужно еще вызвать :set_visibility(true)
]]


Button = {}

function Button:new(x, y, text, size_x, size_y, colors)
    colors = colors or {text=4, chill=10, scared=15, pressed=14, shadow=4}
    -- определяем хитбокс по тексту
    size_x = size_x or #text * 6
    size_y = size_y or 7
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
    }
    setmetatable(object, self)
    return object
end

function Button:update()
    local x, y, left, middle, right = mouse()
    if self.x1 <= x and x <= self.x2 and self.y1 <= y and y <= self.y2 then
        if left then
            self.status = 'pressed'
        else
            self.status = 'scared'
        end
        return
    end
    self.status = 'chill'
end

function Button:draw()
    -- shadow
    rect(self.x1-1, self.y1 +1, self.x2-self.x1+3, self.y2-self.y1, self.color.shadow)
    rect(self.x1, self.y1-1 +1, self.x2-self.x1+1, self.y2-self.y1+2, self.color.shadow)
    if self.status == 'chill' or self.status == 'scared' then
        rect(self.x1-1, self.y1, self.x2-self.x1+3, self.y2-self.y1, self.color[self.status])
        rect(self.x1, self.y1-1, self.x2-self.x1+1, self.y2-self.y1+2, self.color[self.status])
        print(self.text, self.x1+1, self.y1+1, self.color.text)
    else  -- pressed
        rect(self.x1-1, self.y1 +1, self.x2-self.x1+3, self.y2-self.y1, self.color.pressed)
        rect(self.x1, self.y1-1 +1, self.x2-self.x1+1, self.y2-self.y1+2, self.color.pressed)
        print(self.text, self.x1+1, self.y1+1 +1, self.color.text)
    end
end

function Button:set_visibility(flag)
    self.visibility = flag
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

    print(self.text_right, self.x2 + 4, self.y1 + 1, self.color.scared[self.is_on])
end

ToggleButton.__index = ToggleButton


SpriteButton = table.copy(Button)
function SpriteButton:new(x, y, sprites, size_x, size_y)
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
    }
    setmetatable(object, self)
    return object
end

function SpriteButton:draw()
    -- я не уверен что эти формулы корректны, нужно тестить
    local width = (self.x2-self.x1+2+7)/8
    local height = (self.y2-self.y1+2+7)/8
    spr(self.sprite[self.status], self.x1-1, self.y1-1, 0, 1,0,0, width,height)
end


SpriteButton.__index = SpriteButton
