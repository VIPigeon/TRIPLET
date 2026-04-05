
Click = {
    prev_left = false,
    prev_right = false,
    left_buffer = 0,
    right_buffer = 0,
    BUFFER = 0.21,
}

function Click.update()
    local x, y, left, middle, right = mouse()

    Click.left_buffer = Basic.tick_timer(Click.left_buffer)
    if Click.left() then
        Click.left_buffer = Click.BUFFER
    end

    Click.right_buffer = Basic.tick_timer(Click.right_buffer)
    if Click.right() then
        Click.right_buffer = Click.BUFFER
    end

    Click.prev_left = left
    Click.prev_right = right
end

function Click.left()
    local x, y, left, middle, right = mouse()
    return left and not Click.prev_left
end

function Click.right()
    local x, y, left, middle, right = mouse()
    return right and not Click.prev_right
end

function Click.double_left()
    return Click.left() and Click.left_buffer > 0
end

function Click.double_right()
    return Click.right() and Click.right_buffer > 0
end
