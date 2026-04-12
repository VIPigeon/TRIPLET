
BOARD = {
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,

    [28] = true,
    [29] = true,
    [30] = true,
    [31] = true,

    [44] = true,
    [45] = true,
    [46] = true,
    [47] = true,

    -- раньше это был HAND_BORDER ⤵
    -- после перерисовки все перемешалось
    -- HAND_BORDER больше не имеет никакого смысла
    -- а часть тайлов вообще не используется, но я не знаю какая
    -- если вдруг буду снова перерисовывать стол, проведу работу над этим
    -- а пока пусть мертвые тайлы валяются неиспользованными
    [208] = true,
    [209] = true,
    [218] = true,
    [219] = true,

    [224] = true,
    [225] = true,
    [234] = true,
    [235] = true,

    [220] = true,
    [221] = true,
    [236] = true,
    [237] = true,
}
HAND_BORDER = {}  -- чтобы игра не крашилась, лень ходить по файлам и удалять его

HAND = {
    [210] = true,
    [211] = true,
    [212] = true,
    [213] = true,
    [214] = true,
    [215] = true,
    [216] = true,
    [217] = true,

    [226] = true,
    [227] = true,
    [228] = true,
    [229] = true,
    [230] = true,
    [231] = true,
    [232] = true,
    [233] = true,   
}


require 'Vector2D'
require 'Basic'
require 'Table'
require 'TileInfo'
require 'ProgressBar'
require 'gui'
require 'Click'
require 'MoveAnimator'
require 'Tile'
require 'Hand'
require 'Spectator'
require 'ScoringAnimator'
require 'Settings'
-- require 'Cursor' -- курсора не будет
require 'Time'
require 'Game'

-- TIC-80 🤖 обязывает нас объявлять функцию TIC, которую он будет
-- вызывать каждый кадр.
game.init()

function TIC()
    Time.update()
    
    game.update()

    Click.update()
end
