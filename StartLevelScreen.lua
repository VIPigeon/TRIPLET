StartLevelScreen = {}

function StartLevelScreen.draw(name)
    cls(C0)
    local size = 2
    local outline_width = 0
    local is_square = false
    local is_fixed = false

    local x = 120 - #name * size * 6/2
    local y = 53
    local color_text = 11
    local color_outline = 5
    local shadow_color = 5
    TextWithOutline.print(name, x, y+1, outline_width, shadow_color, shadow_color, size, is_square, is_fixed)
    TextWithOutline.print(name, x, y, outline_width, color_text, color_outline, size, is_square, is_fixed)
    -- TextWithOutline.print(name, x-1, y, 0, color_text, color_outline, size, is_square, is_fixed)
    -- TextWithOutline.print(name, x+1, y, 0, color_text, color_outline, size, is_square, is_fixed)
    -- TextWithOutline.print(name, x, y-1, 0, color_text, color_outline, size, is_square, is_fixed)
    -- TextWithOutline.print(name, x, y+1, 0, color_text, color_outline, size, is_square, is_fixed)
end
