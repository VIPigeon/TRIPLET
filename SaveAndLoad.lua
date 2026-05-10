
mem = {}

function mem.save()
    -- прогресс уровней кодируется. больше ничего не сохраняется
    -- trace('save')
    -- for i, level in ipairs(game.level_map.levels) do
    --     trace(i)
    --     trace(pmem(4*i))
    --     trace(pmem(4*i+1))
    --     trace(pmem(4*i+2))
    --     trace(pmem(4*i+3))
    -- end


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
    -- trace('load')
    for i, level in ipairs(game.level_map.levels) do
        -- trace(i)
        -- trace(pmem(4*i))
        -- trace(pmem(4*i+1))
        -- trace(pmem(4*i+2))
        -- trace(pmem(4*i+3))

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