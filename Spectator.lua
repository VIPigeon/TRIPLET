Spectator = {}

function Spectator:new()
    local object = {
        time = 0,
        turns = 0,
        prev_hand_size = 0,
        visible = true,
    }
    setmetatable(object, self)
    return object
end

function Spectator:update()
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
    x = x or 0
    y = y or 16*8
    if Settings.SHOW_TIME_DURING_GAME then
        print("TIME: "..string.format("%.1f", self.time), x, y)
        x = x + 60
    end
    if Settings.SHOW_TURNS_DURING_GAME then
        print("TURNS: "..self.turns, x, y)
    end
end

function Spectator:hide()
    self.visible = false
end


Spectator.__index = Spectator
