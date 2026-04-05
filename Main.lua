
BOARD = {
    [152] = true,
    [153] = true,
    [154] = true,
    [155] = true,

    [168] = true,
    [169] = true,
    [170] = true,
    [171] = true,

    [184] = true,
    [185] = true,
    [186] = true,
    [187] = true,
}

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

HAND_BORDER = {
    [208] = true,
    [209] = true,
    [218] = true,
    [219] = true,

    [224] = true,
    [225] = true,
    [234] = true,
    [235] = true,
}

require 'Vector2D'
require 'Basic'
require 'Click'
require 'MoveAnimator'
require 'Tile'
require 'Hand'
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
