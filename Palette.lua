ADDR = 0x3FC0

palette = {
    normal={
        [5]={135, 168, 137},
        [11]={176, 235, 147},
    },
    dark={
        [5]={95, 118, 96},
        [11]={123, 165, 103},
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
    for i, c in pairs(palette.normal) do
        palette.colorChange(i, c[1], c[2], c[3])
    end
end
function palette.make_dark()
    for i, c in pairs(palette.dark) do
        palette.colorChange(i, c[1], c[2], c[3])
    end
end