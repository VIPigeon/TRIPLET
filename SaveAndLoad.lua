
mem = {}

local keys_settings = {
    'SFX',
    'MUSIC',
    'QUICK',
    'SHOW_TIME_DURING_GAME',
}

function mem.save()
    local settings = 0
    for i, key in ipairs(keys_settings) do
        local s = 0
        if Settings[key] then
            s = 1
        end
        settings = settings + s*(2^(i - 1))
    end
    pmem(0, settings) -- сохраняем настройки как битовую маску

    for i, level in ipairs(game.level_map.levels) do
        if level.is_completed then
            pmem(i*4, level.best_score.score)
            pmem(i*4+1, math.floor(level.best_score.time*10))
            pmem(i*4+2, level.best_time.score)
            pmem(i*4+3, math.floor(level.best_time.time*10))
        else
            pmem(i*4, 0)
            if level.is_available then
                pmem(i*4+1, 1)
            else
                pmem(i*4+1, 0)
            end
        end
    end
end

function mem.clear()    
    for i, level in ipairs(game.level_map.levels) do
        pmem(4*i, 0)
        pmem(4*i+1, 0)
        pmem(4*i+2, 0)
        pmem(4*i+3, 0)
    end
end

function mem.load()
    local settings = pmem(0)
    local values = {}
    for i, _ in ipairs(keys_settings) do
        table.insert(values, (settings % 2 == 1) )
        settings = math.floor(settings / 2)
    end

    -- for _, v in ipairs(values) do
    --     trace(v)
    -- end

    for i, key in ipairs(keys_settings) do
        Settings[key] = values[i]
    end

    for i, level in ipairs(game.level_map.levels) do
        local score_score = pmem(4*i)
        if score_score == 0 then
            level.is_available = (pmem(4*i + 1) == 1)
            level.is_completed = false
        else
            local score_time = pmem(4*i + 1) / 10
            local time_score = pmem(4*i + 2)
            local time_time = pmem(4*i + 3) / 10
            level.best_score = {score=score_score, time=score_time}
            level.best_time = {score=time_score, time=time_time}
            level.is_available = true
            level.is_completed = true
        end
    end
end