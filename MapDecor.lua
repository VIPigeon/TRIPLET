
FLOWER_T = 0.04
SHELL_T = 0.05
BULB_T = 0.23
MapDecor = {
    X = 120,
    Y = 51,
    timers = {},
    is_reverse = {},
    animations = {
        -- bulb
        [60] = 61,
        [61] = 62,
        [62] = -61,
        [-61] = 60,

        -- flower
        [160] = 161,
        [161] = 162,
        [162] = 163,
        [163] = 164,
        [164] = 165,
        [165] = -164,
        [-164] = -163,
        [-163] = -162,
        [-162] = -161,
        [-161] = 160,

        -- shell
        [79] = 95,
        [95] = 111,
        [111] = 127,
        [127] = 143,
        [143] = -127,
        [-127] = -111,
        [-111] = -95,
        [-95] = 79,
    },
    TIMERS = {
        -- bulb
        [60] = 0,
        [61] = BULB_T,
        [62] = 0,
        [-61] = BULB_T,

        -- flower
        [160] = 0,
        [161] = FLOWER_T,
        [162] = FLOWER_T,
        [163] = FLOWER_T,
        [164] = FLOWER_T,
        [165] = 0,
        [-164] = FLOWER_T,
        [-163] = FLOWER_T,
        [-162] = FLOWER_T,
        [-161] = FLOWER_T,

        -- shell
        [79] = 0,
        [95] = SHELL_T,
        [111] = SHELL_T,
        [127] = SHELL_T,
        [143] = 0,
        [-127] = SHELL_T,
        [-111] = SHELL_T,
        [-95] = SHELL_T,
    },

    WISE_ADVICE = {  -- надписи на табличках привязаны к их абсолютным координатам на карте
        base_advice = {"Create your own rules", "to remember cards easier.", "Use your imagination!"},
        autodraw_advice = {"RMB and double click", "add a card to your hand", "automatically."},
    },
    ADVICE_NAMES = {  -- надписи на табличках привязаны к их абсолютным координатам на карте
        ['138 58'] = 'base_advice',
        ['132 59'] = 'autodraw_advice',
    },

    ADVICE_STATES = {
        chill = 126,
        scared = 142,
        pressed = 158,
    },
}

function MapDecor.get_advice_name(x, y)
    local key = tostring(x)..' '..tostring(y)
    return MapDecor.ADVICE_NAMES[key]
end

function MapDecor.init()
    for x = 1, 30 do
        table.insert(MapDecor.timers, {})
        table.insert(MapDecor.is_reverse, {})
        for y = 1, 17 do
            table.insert(MapDecor.timers[x], 0)
            table.insert(MapDecor.is_reverse[x], false)

            local tile_x = x + MapDecor.X - 1
            local tile_y = y + MapDecor.Y - 1
            local advice = MapDecor.get_advice_name(tile_x, tile_y)
            if advice then
                local button = AdviceButton:new(x*8-8, y*8-8, MapDecor.ADVICE_STATES, 8, 8)
                button.advice = MapDecor.WISE_ADVICE[advice]  -- буду использовать при отрисовке. Да, опять плохой код
                button:set_window_status('button')
                game.buttons[advice] = button
                mset(tile_x, tile_y, 0)
            end
        end
    end
end

function MapDecor.update_click()
    if not ( Click.left() or Click.right() ) then
        return
    end
    local x, y, left, middle, right = mouse()
    local tile_x = math.floor(x / 8) + MapDecor.X
    local tile_y = math.floor(y / 8) + MapDecor.Y
    local tile = mget(tile_x, tile_y)
    if table.contains(MapDecor.animations, tile) then
        MapDecor.change_frame(tile_x, tile_y)
        -- local table_x = tile_x - MapDecor.X + 1
        -- local table_y = tile_y - MapDecor.Y + 1
        -- if MapDecor.is_reverse[table_x][table_y] then
        --     -- ⚠️ меняется знак tile
        --     tile = -tile
        -- end
        -- local next_tile = MapDecor.animations[tile]
        -- if next_tile < 0 then
        --     next_tile = -next_tile
        --     MapDecor.is_reverse[table_x][table_y] = true
        -- else
        --     MapDecor.is_reverse[table_x][table_y] = false
        -- end
        -- mset(tile_x, tile_y, next_tile)
        -- MapDecor.timers[table_x][table_y] = MapDecor.TIMERS[next_tile]
    end
end


function MapDecor.change_frame(tile_x, tile_y)
    local tile = mget(tile_x, tile_y)
    local table_x = tile_x - MapDecor.X + 1
    local table_y = tile_y - MapDecor.Y + 1
    if MapDecor.is_reverse[table_x][table_y] then
        -- ⚠️ меняется знак tile
        tile = -tile
    end
    local next_tile = MapDecor.animations[tile]
    if next_tile < 0 then
        next_tile = -next_tile
        MapDecor.is_reverse[table_x][table_y] = true
    else
        MapDecor.is_reverse[table_x][table_y] = false
    end
    mset(tile_x, tile_y, next_tile)
    MapDecor.timers[table_x][table_y] = MapDecor.TIMERS[next_tile]
end

function MapDecor.update_animations()
    for x = 1, 30 do
        for y = 1, 17 do
            if MapDecor.timers[x][y] > 0 then
                MapDecor.timers[x][y] = Basic.tick_timer(MapDecor.timers[x][y])
                -- ♈ один компьютерный кадр прокручивается ради преждевременной оптимизации
                if MapDecor.timers[x][y] == 0 then
                    MapDecor.change_frame(x-1+MapDecor.X, y-1+MapDecor.Y)
                end
            end
        end
    end
end


function MapDecor.update()
    MapDecor.update_animations()
    MapDecor.update_click()
end

function MapDecor.draw()
    map(MapDecor.X, MapDecor.Y, 30,17,0,0, 0)
end

