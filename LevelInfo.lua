
ALL_ANIMALS = {416, 418}
for i = 256, 384, 32 do
    for j = 0, 14, 2 do
        table.insert(ALL_ANIMALS, i+j)
    end
end

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
    ['38 13'] = 'SLOTS',

    ['42 5'] = 'DRAFT',
    ['44 5'] = 'ROSE-TINTED',
    ['42 7'] = 'RORSCHACH',
    ['44 7'] = 'NIGHT',

    ['40 13'] = 'TIME IS SCORE',
    ['44 3'] = 'BOSS',
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

LEVEL_SIZE = {  -- количество ВИДОВ
    ['GETTING STARTED'] = 3,
    ['LAMA LEVEL'] = 6,
    ['BRIDGE'] = 6,
    ['UPSIDE DOWN'] = 33,
    ['TAKE FIVE'] = 5,
    ['REVERSE'] = 6,
    
    ['AFTERPARTY'] = 6,
    ['CROCODILE LEVEL'] = 6,
    ['DEJA VU'] = 6,
    
    ['CONVEYOR'] = 6,
    ['GRAVITATION'] = 3,
    ['SLIP BOARD'] = 3,
    ['SHY CARDS'] = 6,
    ['SLOTS'] = 3,
    
    ['DRAFT'] = 3,
    ['ROSE-TINTED'] = 3,
    ['RORSCHACH'] = 3,
    ['NIGHT'] = 3,
    
    ['TIME IS SCORE'] = 6,
    ['BOSS'] = 3,
}
LEVEL_COPIES_OF_EACH_ANIMAL = {
    ['GETTING STARTED'] = 3,
    ['LAMA LEVEL'] = 6,
    ['BRIDGE'] = 6,
    ['UPSIDE DOWN'] = 3,
    ['TAKE FIVE'] = 5,
    ['REVERSE'] = 6,
    
    ['AFTERPARTY'] = 6,
    ['CROCODILE LEVEL'] = 6,
    ['DEJA VU'] = 6,
    
    ['CONVEYOR'] = 6,
    ['GRAVITATION'] = 3,
    ['SLIP BOARD'] = 3,
    ['SHY CARDS'] = 6,
    ['SLOTS'] = 3,
    
    ['DRAFT'] = 3,
    ['ROSE-TINTED'] = 3,
    ['RORSCHACH'] = 3,
    ['NIGHT'] = 3,
    
    ['TIME IS SCORE'] = 6,
    ['BOSS'] = 3,
}

LEVEL_BOARD = {
    ['BRIDGE'] = {x=0, y=17},
    ['UPSIDE DOWN'] = {x=60, y=17},
    ['TAKE FIVE'] = {x=60, y=0},
    ['CONVEYOR'] = {x=30, y=34},
}


local base_pool = {396, 256, 298, 360, 268, 300}
local sea_pool = {384, 386, 388, 390, 392, 394, 396, 398}

LEVEL_POOL = {}
