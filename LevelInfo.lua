
LEVEL_NAME = {
    -- start
    ['34 5'] = 'GETTING STARTED', ['36 5'] = 'CLASSIC #1', ['38 5'] = 'DUPLICATES #2',
    ['34 7'] = 'DUPLICATES #1', ['36 7'] = 'COAST', ['38 7'] = 'CLASSIC #2',

    -- water
    ['36 9'] = 'COASTAL WATERS',
    ['36 11'] = 'OPEN SEA', ['38 11'] = 'CONTINENTAL SHELF',
    ['36 13'] = 'DEEP SEA', ['38 13'] = 'A LOT OF FISH',

    -- challenge
    ['42 5'] = 'LAMA LEVEL', ['44 5'] = 'HARD CHALLENGE',
    ['40 7'] = 'BRIDGE', ['42 7'] = 'EASY CHALLENGE', ['44 7'] = 'MEDIUM CHALLENGE',
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

local base_pool = {396, 256, 298, 360, 268, 300}
local sea_pool = {384, 386, 388, 390, 392, 394, 396, 398}
local challenge_pool = {
    360, 362, 364, 366, -- lamas
    396, 398, -- from sea_pool
    256, 298, 268, 300, -- from base_pool
    262, 264, -- river-horse
    266, -- self-insert
    260, 270,
}

LEVEL_POOL = {
    -- start
    ['34 5'] = base_pool, ['36 5'] = base_pool, ['38 5'] = base_pool,
    ['34 7'] = base_pool, ['36 7'] = {262, 264, 396, 398}, ['38 7'] = base_pool,

    -- water
    ['36 9'] = sea_pool,
    ['36 11'] = sea_pool, ['38 11'] = sea_pool,
    ['36 13'] = sea_pool, ['38 13'] = sea_pool,

    -- challenge
    ['42 5'] = {360, 362, 364, 366}, ['44 5'] = challenge_pool,
    ['40 7'] = {260, 270, 266, 362, 364}, ['42 7'] = challenge_pool, ['44 7'] = challenge_pool,
}
LEVEL_DIVERSITY = {
    -- start
    ['34 5'] = 3, ['36 5'] = 4, ['38 5'] = 4,
    ['34 7'] = 3, ['36 7'] = 4, ['38 7'] = 5,

    -- water
    ['36 9'] = 3,
    ['36 11'] = 4, ['38 11'] = 6,
    ['36 13'] = 5, ['38 13'] = 6,

    -- challenge
    ['42 5'] = 4, ['44 5'] = 12,
    ['40 7'] = 3, ['42 7'] = 8, ['44 7'] = 10,
}
LEVEL_TRIPLETS = {
    -- start
    ['34 5'] = 3, ['36 5'] = 4, ['38 5'] = 8,
    ['34 7'] = 6, ['36 7'] = 4, ['38 7'] = 5,

    -- water
    ['36 9'] = 6,
    ['36 11'] = 8, ['38 11'] = 6,
    ['36 13'] = 10, ['38 13'] = 13,

    -- challenge
    ['42 5'] = 10, ['44 5'] = 12,
    ['40 7'] = 4, ['42 7'] = 8, ['44 7'] = 10,
}
-- LEVEL_LAYOUT = {
--     ['34 5'] = 'random',
--     ['36 5'] = 'random',
--     ['38 5'] = 'random',
--     ['36 7'] = 'random',
--     ['38 7']  = 'random',
--     ['40 7']  = 'random',
--     ['42 7']  = 'random',
--     ['36 9']  = 'random',
--     ['36 11'] = 'random',
--     ['36 11'] = 'random',
--     ['38 11'] = 'random',
--     ['36 13'] = 'random',
--     ['38 13'] = 'random',
-- }