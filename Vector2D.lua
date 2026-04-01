
-- векторная алгебра
vector2d = {}

function vector2d.dot(v1, v2)
    return v1.x*v2.x + v1.y*v2.y
end

function vector2d.cross(v1, v2)
    return v1.x*v2.y - v1.y*v2.x
end

function vector2d.abs(v)
    return math.sqrt(vector2d.dot(v, v))
end

function vector2d.normalize(v)
    local length = math.sqrt(v.x^2 + v.y^2)
    
    if length == 0 then
        return {x=0, y=0} -- чтобы избежать деления на ноль
    end
    
    return {x = v.x/length, y = v.y/length}
end