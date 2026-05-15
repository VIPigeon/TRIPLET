
ALL_ANIMALS = {416, 418}
for i = 256, 384, 32 do
    for j = 0, 14, 2 do
        table.insert(ALL_ANIMALS, i+j)
    end
end

FIRST_LEVEL_NAME = 'GETTING STARTED'

LEVEL_NAME = {
    ['34 5'] = 'GETTING STARTED',
    ['36 5'] = 'LAMA LEVEL',

    ['40 7'] = 'BRIDGE',
    ['48 5'] = 'UPSIDE DOWN',
    ['50 5'] = 'TAKE FIVE',
    ['36 7'] = 'REVERSE',

    ['38 7'] = 'AFTERPARTY',
    ['38 5'] = 'CROCODILE LEVEL',
    ['34 7'] = 'DEJA VU',

    ['36 9'] = 'CONVEYOR',
    ['36 11'] = 'GRAVITATION',
    ['38 11'] = 'SLIP BOARD',
    ['36 13'] = 'SHY CARDS',
    ['38 13'] = 'SUPERPOSITION',

    ['42 5'] = 'DRAFT',
    ['44 5'] = 'ROSE-TINTED',
    ['42 7'] = 'RORSCHACH',
    ['44 7'] = 'NIGHT',

    ['40 13'] = 'TIME IS SCORE',
    ['44 3'] = 'BOSS',

    ['48 7'] = 'XS',
    ['50 7'] = 'WINDOW',
    ['48 9'] = 'NOIR',  -- таже игра с палитрой, только здесь она чб
    ['50 9'] = 'TAKE FIVE 2',
}
LEVEL_DESCRIPTION = {
    -- start
    ['34 5'] = {"", "Use mouse for drag'n'drop cards.", "", "Collect a three same animals", "to gain a Triplet!"}, ['36 5'] = {"", "Use right click for fast draw"}, ['38 5'] = {":)"},
    ['34 7'] = {'^_^'}, ['36 7'] = {':O'}, ['38 7'] = {"", "Several triplets in a row create a combo", "", "The longer the combo, the more score"},

    -- water
    ['36 9'] = {':P'},
    ['36 11'] = {':|'}, ['38 11'] = {'<3'},
    ['36 13'] = {':D'}, ['38 13'] = {'', '<(((*>', '<(((*>', '<(((*>'},

    -- challenge
    ['42 5'] = {'XD'}, ['44 5'] = {'T_T'},
    ['40 7'] = {"", "There is only new animals"}, ['42 7'] = {'-_-'}, ['44 7'] = {'o_O'},
}

-- ⚙️ помечаем уровни, которые ТЕХНИЧЕСКИ готовы
-- ⭐ помечаем уровни, которые готовы ПОЛНОСТЬЮ, то есть с набором животных
-- 😪 помечаем уровни, которые я не хочу делать
LEVEL_SIZE = {  -- количество ВИДОВ
    ['GETTING STARTED'] = 1,
    ['LAMA LEVEL'] = 4,
    ['BRIDGE'] = 6, -- ⚙️
    ['UPSIDE DOWN'] = 7, -- ⚙️
    ['TAKE FIVE'] = 10, -- ⚙️
    ['REVERSE'] = 6, -- ⚙️
    
    ['AFTERPARTY'] = 6, -- ⚙️
    ['CROCODILE LEVEL'] = 2, -- ⚙️
    ['DEJA VU'] = 6,
    
    ['CONVEYOR'] = 6, -- 😪
    ['GRAVITATION'] = 6, -- ⚙️
    ['SLIP BOARD'] = 4, -- ⚙️
    ['SHY CARDS'] = 6, -- 😪
    ['SUPERPOSITION'] = 5,
    
    ['DRAFT'] = 3, -- 😪
    ['ROSE-TINTED'] = 3, -- ⚙️
    ['RORSCHACH'] = 3, -- 😪
    ['NIGHT'] = 18,
    
    -- ['TIME IS SCORE'] = 6, -- 😪
    ['ENDLESS MODE'] = 3, -- 😪 переименовать в ENDLESS
    ['XS'] = 6, -- ⚙️
    ['WINDOW'] = 7, -- ⚙️

    -- ['SHAKE'] = 3,
    ['TAKE FIVE 2'] = 20, -- мне очень понравился этот уровень, поэтому я хочу сделать его увеличенную версию
}
LEVEL_COPIES_OF_EACH_ANIMAL = {
    ['GETTING STARTED'] = 3, -- для дебага
    ['LAMA LEVEL'] = 6,
    ['BRIDGE'] = 6,
    ['UPSIDE DOWN'] = 3,
    ['TAKE FIVE'] = 5,
    ['TAKE FIVE 2'] = 5,
    ['REVERSE'] = 6,
    
    -- в afterparty уникальные тройки:
    -- один и тот же вид представлен в двух отедльных наборах, но с разным поворотом
    ['AFTERPARTY'] = 6,

    ['CROCODILE LEVEL'] = 8*3, -- костыль
    ['DEJA VU'] = 3,
    
    ['CONVEYOR'] = 6,
    ['GRAVITATION'] = 3,
    ['SLIP BOARD'] = 3,
    ['SHY CARDS'] = 6,
    ['SUPERPOSITION'] = 6, -- костыль
    
    ['DRAFT'] = 3,
    ['ROSE-TINTED'] = 3,
    ['RORSCHACH'] = 3,
    ['NIGHT'] = 3,
    
    -- ['TIME IS SCORE'] = 6,
    ['ENDLESS MODE'] = 3,
    ['XS'] = 6,
    ['WINDOW'] = 6,
}

LEVEL_BOARD = {
    ['BRIDGE'] = {x=0, y=17},
    ['UPSIDE DOWN'] = {x=60, y=17},
    ['TAKE FIVE'] = {x=60, y=0},
    ['TAKE FIVE 2'] = {x=60, y=0},
    ['CONVEYOR'] = {x=30, y=34},
    ['XS'] = {x=0, y=34},
    ['WINDOW'] = {x=0, y=51},
    ['GRAVITATION'] = {x=60, y=17},
    -- ['SLIP BOARD'] = {x=30, y=51},
}

LEVEL_LAYOUT = {
    ['BRIDGE'] = {
        x1 = 8*2, y1 = 8*3,
        x2 = 8*8, y2 = 8*(31-17)
    },
    ['WINDOW'] = {
        x1 = 8*2, y1 = 8*3 - 3,
        x2 = 8*24+5, y2 = 8*3 + 2,
    },
    ['UPSIDE DOWN'] = {
        x1 = 8*10 - 1, y1 = 8*7 - 1,
        x2 = 8*17 - 4, y2 = 8*11 - 4,
    },
}
LEVEL_LAYOUT['GRAVITATION'] = LEVEL_LAYOUT['UPSIDE DOWN']

local base_pool = {396, 256, 298, 360, 268, 300}
local lama_pool = {360, 362, 364, 366}
local green_pool = {266, 268, 292, 324, 398}
local river_pool = {262, 264, 266, 268, 270, 322}
local flying_pool = {292, 298, 356, 328, 330, 416}
local insects_pool = {322, 324, 326, 328, 330, 332, 334}
local sea_pool = {384, 386, 388, 390, 392, 394, 396, 398}
local black_and_grey_pool = {
    290, 298, 320, 362, -- black
    352, 354, 356, 358, 392, 294, -- grey
}
local autumn_pool = {256, 258, 270, 260, 288, 296, 302, 322, 328, 330, 334, 386, 388, 390, 396}

LEVEL_POOL = {
    ['CROCODILE LEVEL'] = {266, 448},
    ['LAMA LEVEL'] = lama_pool,
}
