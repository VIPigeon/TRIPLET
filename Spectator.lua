Spectator = {}
-- теперь спектатор только считает время

function Spectator:new()
    local object = {
        time = 0,
        turns = 0,  -- не нужны
        prev_hand_size = 0,
        visible = true,
        stop = false
    }
    setmetatable(object, self)
    return object
end

function Spectator:update()
    if self.stop then
        return
    end
    self.time = self.time + Time.dt()
    local hand_size = hand.size()
    if hand_size > self.prev_hand_size then
        self.turns = self.turns + 1
    end
    self.prev_hand_size = hand_size
end

function Spectator:draw(x, y)
    if not self.visible then
        return
    end
    -- x = x or 0
    -- y = y or 16*8+3
    x = x or 26*8 + 1
    y = y or 0

    if Settings.SHOW_TIME_DURING_GAME then
        -- print("TIME: "..string.format("%.1f", self.time), x, y)
        spr(240 + (self.time - math.floor(self.time))/0.125, x+4, y)
        -- print("   time: "..math.floor(self.time), x, y, 11)
        local t = math.floor(self.time)
        if t > 999 then
            t = t % 1000
            if t < 10 then
                t = '00'..t
            elseif t < 100 then
                t = '0'..t
            end
        end
        print("   "..t, x+2, y, 11)
        -- x = x + 39
        -- if self.time > 9 then
        --     x = x + 4
        -- end
        -- if self.time > 99 then
        --     x = x + 4
        -- end
        -- if self.time > 999 then
        --     x = x + 4
        -- end
        -- spr(450 + (self.time - math.floor(self.time))/0.125, x, y)
    end
end

function Spectator:hide()
    self.visible = false
end

function Spectator:stop()
    self.stop = true
end


Spectator.__index = Spectator
