MainMenu = {}

function MainMenu.draw()
    MapDecor.draw()
    map(30, 0, 30,17,0,0, 0)

    local MAIN_COLOR = 11
    local OUTLINE_COLOR = 5
    local TEXT = "TRIPLET!"
    local OUTLINE_WIDTH = 1
    local X = (5*8)
    local Y = (4*8+16)
    local SIZE = 4
    local function pprint(X, Y, MAIN_COLOR)
        print(TEXT, X-OUTLINE_WIDTH, Y, MAIN_COLOR, false, SIZE)
        print(TEXT, X+OUTLINE_WIDTH, Y, MAIN_COLOR, false, SIZE)
        print(TEXT, X, Y-OUTLINE_WIDTH, MAIN_COLOR, false, SIZE)
        print(TEXT, X, Y+OUTLINE_WIDTH, MAIN_COLOR, false, SIZE)
    end

    pprint(X, Y+4, OUTLINE_COLOR)
    pprint(X, Y-4, OUTLINE_COLOR)
    pprint(X+4, Y, OUTLINE_COLOR)
    pprint(X-4, Y, OUTLINE_COLOR)

    pprint(X+3, Y+2, OUTLINE_COLOR)
    pprint(X+2, Y+3, OUTLINE_COLOR)

    pprint(X+3, Y-2, OUTLINE_COLOR)
    pprint(X+2, Y-3, OUTLINE_COLOR)

    pprint(X-3, Y-2, OUTLINE_COLOR)
    pprint(X-2, Y-3, OUTLINE_COLOR)

    pprint(X-3, Y+2, OUTLINE_COLOR)
    pprint(X-2, Y+3, OUTLINE_COLOR)

    pprint(X, Y, MAIN_COLOR)

    -- кредиты
    local vcroc = "A GAME BY V. CROCODILE"
    local green = 5
    print(vcroc, 15*8+2, 0, green)
    --
end
