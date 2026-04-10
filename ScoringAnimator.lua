
ScoringAnimator = {}

ScoringAnimator.SCORE_BY_TILE = 50
ScoringAnimator.SCORE_BY_TURN = 10
ScoringAnimator.TEXT_SLOTS = {
    tiles = {x=7*8-4, y=13*8+5},
    turns = {x=7*8-4, y=13*8+5-14},
    time = {x=7*8-4, y=13*8+5-28},
}
ScoringAnimator.TEXT_COLOR = {
    tiles=14,
    turns=13,
    time=6,
}

function ScoringAnimator:new(time, turns)
    local object = {
        time=time,
        turns=turns,
        i=1,
    }
    setmetatable(object, self)
    return object
end


function ScoringAnimator:update(tiles)
    if self.i > #tiles then
        return
    end

    if tiles[self.i]:is_scored() then
        self.i = self.i + 1
    end
end

function ScoringAnimator:get_score_for_tiles()
    -- для отрисовки
    return (self.i-1) * ScoringAnimator.SCORE_BY_TILE
end

function ScoringAnimator:is_end(tiles)  -- извините
    return #tiles < self.i
end

ScoringAnimator.__index = ScoringAnimator
