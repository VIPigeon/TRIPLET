
-- у каждого животного будет своё имя. так мне будет легче ориентироваться
-- FunFacts = {
--     ["Colorful lama"] = "It looks a bit lika a pinata. Please don't hit it",
--     Hippopotamus = "Often confused with a river-horse",
--     ["River horse"] = "Often confused with a hippopotamus",
--     Peacock = "The peacock’s tail span reaches 9 pixels",
--     Crow = "The wingspan of a crow can reach up to about 1 meter",
--     Capibara = "It has a mandarin on it's head",
--     ["Pink lama"] = "I love you",
--     Panda = "Coffee makes panda insane",
--     Hedgehog = "A hedgehog can be surprisingly fast. There is a known case of a hedgehog being discovered that could exceed the speed of sound.",
--     ["Baby elephant"] = "Normal elephant didn't fit on the card",
--     Sloth = "",  -- лень писать факт
--     Goldfish = "The goldfish grants wishes. I wish you like this game",
--     Snail = "я еще не придумал. но если будет анимация вывода букв, я замедлю ее",
--     Butterfly = "There is no butter",  -- нужно написать шутку в духе каракатица никуда не катится
-- }

--[[
всего 42 вида животных и 8 уровней, включая туториал.

перерабатываем идею уникальных тайлов: все предыдущие животные добавляются
42 вида. 30 обычных и 12 редких

3: 3/3 обычных
7: 6/9 обычных 1 редкий
11: 9/13 обычных 2 редких
15: 12/18 обычных 3 редких
19: 15/22 обычных 4 редких
23: 18/27 обычных 5 редких
27: 21/29 обычных 6 редких
31: 24/30 обычных 7 редких

суть в том, что чанки обычных тайлов растут, а вот редких — нет. любой редкий может попастся на любом уровне
это должно создать впечатление как раз-таки редкости этих животных

]]


local tile_values = {}
for i = 256, 384, 32 do
    for di = 0, 14, 2 do
        table.insert(tile_values, i+di)
    end
end
table.insert(tile_values, 416)
table.insert(tile_values, 418)

-- с каждым уровнем добавляются обычные тайлы
common_tiles = {}
local need_to_add = {
    4, 2, 2, 2, 2, 2, 3,
    3, 3, 3, 1, 1, 1, 1,
}
local current_i = 1
local current_tiles = {}
for level = 1, 14 do
    for _ = 1, need_to_add[level] do
        table.insert(current_tiles, tile_values[current_i])
        current_i = current_i + 1
    end
    table.insert(common_tiles, table.copy(current_tiles))
end
-- чем позже добавляются обычные тайлы, тем более копиумные у них факты

-- редкие тайлы общие на все уровни
rare_tiles = {
    364, 366,
    384, 386, 388, 390, 392, 394, 396, 398,
    416, 418
}

