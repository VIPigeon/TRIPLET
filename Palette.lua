ADDR = 0x3FC0

palette = {
    color = 'green',
    green={
        [0] = {40, 40, 46},
        [1] = {108, 86, 113},
        [2] = {217, 200, 191},
        [3] = {179, 227, 218},
        [4] = {222, 163, 139},
        [5] = {135, 168, 137},
        [6] = {249, 130, 132},
        [7] = {254, 170, 228},
        [8] = {141, 182, 206},
        [9] = {255, 195, 132},
        [10] = {255, 230, 198},
        [11] = {176, 235, 147},
        -- [12] = {255, 245, 165},
        [12] = {255, 15*16 + 5, 11*16 + 14},
        [13] = {176, 169, 228},
        [14] = {15*16 + 6, 13*16 + 14, 8*16 + 1},
        [15] = {16*15 + 10, 16*15 + 6, 16*14 + 14},
    },
    dark={
        green = {
            [5]={95, 118, 96},
            [11]={123, 165, 103},
        },
        pink = {
            [5]  = {110, 92, 118},
            [11] = {160, 145, 145},
        }
    },
    pink={
        [0] = {49, 38, 50},
        [1] = {121, 92, 122},
        [2] = {228, 196, 205},
        [3] = {205, 214, 220},
        [4] = {228, 160, 165},
        [5] = {148, 154, 150},
        [6] = {240, 132, 150},
        [7] = {242, 170, 220},
        [8] = {162, 174, 214},
        [9] = {240, 190, 165},
        [10] = {245, 225, 220},
        [11] = {196, 214, 180},
        [12] = {245, 230, 185},
        [13] = {190, 170, 230},
        [14] = {240, 224, 150},
        [15] = {250, 240, 235},
    },
}

function palette.colorChange(id, red, green, blue)
    -- id -- color index in tic80 palette
    -- red, green, blue -- new color parameters
    poke(ADDR+(id*3), red)
    poke(ADDR+(id*3)+1, green)
    poke(ADDR+(id*3)+2, blue)
end

function palette.make_normal()
    for i, c in pairs(palette[palette.color]) do
        palette.colorChange(i, c[1], c[2], c[3])
    end
end
function palette.make_dark()
    for i, c in pairs(palette.dark[palette.color]) do
        palette.colorChange(i, c[1], c[2], c[3])
    end
end

function palette.set_color(color)
    palette.color = color
    palette.make_normal()
end
