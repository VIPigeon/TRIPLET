CreditsScreen = {}

function CreditsScreen.draw()
    -- cls(C0) -- фул очистка экрана. *потом* сделаю map

    local dotown = {"A GAME BY V. CROCODILE", "","", "Huge thanks to", "DOTOWN Maeda Design Room for images", "that I shamelessly stole"}
    local x = 24
    local y = 24
    local dy = 9
    local color = 10
    for _, line in ipairs(dotown) do
        print(line, x, y, color)
        y = y + dy
    end
end
