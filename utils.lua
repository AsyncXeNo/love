
-- Some basic util functions


function normalize(x, y)  -- Normalizes a vector
    magnitude = math.sqrt(x*x + y*y)
    if magnitude == 0 then return { x = 0, y = 0 } end
    return { x = x / magnitude, y = y / magnitude }
end


function boolToInt(value)
    if value == true then return 1 else return 0 end
end


function serialize(o, file)  -- Writes highscores to a file
    file = io.open(file, 'w')
    if type(o) == "number" then
        file:write(o)
        file:close()
    elseif type(o) == "string" then
        file:write(string.format("%q", o))
        file:close()
    elseif type(o) == "table" then
        -- io.write("{\n")
        for _,v in pairs(o) do
            file:write(v[1] .. ',' .. v[2] .. '\n')
        end
        file:close()
    else
        file:close()
        error("cannot serialize a " .. type(o))
    end
end


function split(inputstr, sep)  -- Splits a string
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


function smallFont()
    font = love.graphics.newFont('font.ttf', 12)
    font:setLineHeight(1.5)
    love.graphics.setFont(font)
end


function mediumFont()
    font = love.graphics.newFont('font.ttf', 15)
    font:setLineHeight(1.5)
    love.graphics.setFont(font)
end


function largeFont()
    font = love.graphics.newFont('font.ttf', 25)
    font:setLineHeight(1.5)
    love.graphics.setFont(font)
end


function distanceBetweenVectors(v1, v2)  -- Returns distance between two vectors
    x = math.abs(v1.x - v2.x)
    y = math.abs(v1.y - v2.y)
    return math.sqrt(x*x + y*y)
end


function collisionDetectionCC(circle1, circle2)  -- CC stands for circle-circle
    if distanceBetweenVectors(circle1.pos, circle2.pos) <= circle1.radius + circle2.radius then
        return true
    end
    return false
end


function collisionDetectionCS(circle, square)  -- CD stands for circle-square
    distx = math.abs(circle.pos.x - square.pos.x)
    disty = math.abs(circle.pos.y - square.pos.y)

    if (distx > (square.side / 2 + circle.radius)) then
        return false
    end
    if (disty > (square.side / 2 + circle.radius)) then
        return false
    end
    if (distx <= square.side / 2) then
        return true
    end
    if (disty <= square.side / 2) then
        return true
    end

    cornerDistanceSq = (distx - square.side / 2)*(distx - square.side / 2) + (disty - square.side / 2)*(disty - square.side / 2)

    return cornerDistanceSq <= circle.radius*circle.radius
end


function direction(v1, v2)  -- Returns direction from one vector to another
    x = v2.x - v1.x
    y = v2.y - v1.y

    return normalize(x, y)
end


function setLength(set)  -- Returns length of a set in lua
    len = 0
    for _,_ in pairs(set) do
        len = len + 1
    end
    return len
end


return {
    normalize = normalize,
    boolToInt = boolToInt,
    serialize = serialize,
    split = split,
    smallFont = smallFont,
    mediumFont = mediumFont,
    largeFont = largeFont,
    distanceBetweenVectors = distanceBetweenVectors,
    collisionDetectionCC = collisionDetectionCC,
    collisionDetectionCS = collisionDetectionCS,
    direction = direction,
    setLength = setLength
}
