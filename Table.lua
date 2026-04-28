--[[

Функции для таблиц, которым давно бы уже пора появится в lua,
но у бразильцев никак не доходят руки.

Про deep X: Если у нас есть такая таблица:

x = {
    y = {
        69
    }
}

И мы сделаем например table.copy():

z = table.copy(x)

То x.y и z.y будут ссылаться на одну и ту же таблицу y.

Имейте в виду, если кто побежит с таким багом плакаться ко мне,
я его тыкну носом в эту документацию 😈. Читайте её!

--]]

-- Не deep copy
function table.copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

-- 🧹
function table.clear(t)
    for k in pairs (t) do
        t[k] = nil
    end
end

-- Не deep equal
function table.iequals(t1, t2)
    for i, value in ipairs(t1) do
        if value ~= t2[i] then
            return false
        end
    end
    return true
end

-- Не deep equal
function table.equals(t1, t2)
    for i, value in pairs(t1) do
        if value ~= t2[i] then
            return false
        end
    end
    return true
end

-- Добавляет к таблице destination всё из таблицы source.
-- Это не deep copy
function table.concat_table(destination, source)
    for _, element in ipairs(source) do
        table.insert(destination, element)
    end
end

function table.contains_table(t, element)
    for _, value in pairs(t) do
        if table.equals(value, element) then
            return true
        end
    end
    return false
end

function table.contains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end

function table.remove_element(t, element)
    ind = 0
    for i, value in ipairs(t) do
        if value == element then
            ind = i
            break
        end
    end

    if ind > 0 and ind <= #t then -- 😁😁😁😁 Тут был '<' я его полтора часа исправлял на '<='
        table.remove(t, ind)
    end
end

function table.remove_elements(t, removed)
    for i, value in ipairs(t) do
        if table.contains(removed, value) then
            table.remove(t, i)
        end
    end
end

function table.reversed(t)
    res = {}
    for i = #t, 1, -1 do
        table.insert(res, t[i])
    end
    return res
end

function table.length(t) -- 🤓
    local counter = 0
    for _ in pairs(t) do
        counter = counter + 1
    end
    return counter
end

function table.choose_random_element(t)
    local rand = math.random(table.length(t))
    local ind = 1
    local choosen = nil 
    for _, elem in pairs(t) do
        if ind == rand then
            choosen = elem
        end
        ind = ind + 1
    end
    return choosen
end
