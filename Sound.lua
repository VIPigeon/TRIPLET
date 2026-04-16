
Sound = {}

-- звуки тайлов находятся в смене статуса

Sound.arpegio = {
    'G-','D-','A#','D-', i=1, size=4,
}

Sound.arpegio = {
    'G-','D-','A#','D-', i=1, size=4,
}

function Sound.get_arpegio_note(octave)
    local i = Sound.arpegio.i
    if i % 2 == 0 then  -- для ноты D
        octave = octave + 1
    end
    local note = Sound.arpegio[i]..tostring(octave)
    return note
end

function Sound.update_arpegio_note()
    local i = Sound.arpegio.i
    Sound.arpegio.i = i % Sound.arpegio.size + 1
end

function Sound.tile_click()
    -- звук, когда на тайл нажимают
    if not Settings.SFX then
        return
    end
    local hit = Sound.get_arpegio_note(5)
    -- local bell = Sound.get_arpegio_note(7)
    sfx(3, hit, -1, 0)
    -- sfx(1, bell, -1, 1)
    Sound.update_arpegio_note()
end

function Sound.tile_drop()
    -- звук, когда тайл отпускают
    if not Settings.SFX then
        return
    end
    local hit = Sound.get_arpegio_note(4)
    sfx(3, hit, -1, 0)
end


Sound.tile_draw_arpegio = {{id=0, note='G-4'}, {id=2, note='A#4'}, {id=1, note='D-5'}}
function Sound.tile_draw()
    -- звук, когда тайл добавляется у руку
    if not Settings.SFX then
        return
    end
    local i = hand.size() + 1
    sfx(Sound.tile_draw_arpegio[i].id, Sound.tile_draw_arpegio[i].note, -1, 1)
    -- Sound.tile_draw_arpegio.i = i % Sound.tile_draw_arpegio.size + 1
end

function Sound.tile_score()
    if not Settings.SFX then
        return
    end
    -- звук, когда тайл скорится при подсчете очков
end

function Sound.triplet()
    if not Settings.SFX then
        return
    end
    -- звук, когда собирается триплет
    sfx(4, 'F#6', -1, 2)
end

function Sound.hand_is_full()
    if not Settings.SFX then
        return
    end
    -- звук, когда игрок удерживает карту, но рука полная
    -- звук не должен быть раздражающим, потому что игрок не всегда может хотеть взять карту в руку
    sfx(5, 'A#2', -1, 1)
end

function Sound.cant_get_a_card()
    if not Settings.SFX then
        return
    end
    -- звук, когда игрок пытается взять карты правым кликом, но рука полная
    sfx(6, 'A#2', -1, 1) -- то же самое что и hand_is_full, только немного громче
end
