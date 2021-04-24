
function dont_rotate(m)
    return m
end

function rotate_CCW_90(m)
    local rotated = {}
    for c, m_1_c in ipairs(m[1]) do
        local col = {m_1_c}
        for r = 2, #m do
            col[r] = m[r][c]
        end
        table.insert(rotated, 1, col)
    end
    return rotated
end

function rotate_180(m)
    return rotate_CCW_90(rotate_CCW_90(m))
end

function rotate_CW_90(m)
    return rotate_CCW_90(rotate_CCW_90(rotate_CCW_90(m)))
end

--
--function showTetrisBlock(table, rotate_function, i, j, color)
--
--    local table = rotate_function(table)
--
--    local tI = 0
--    for tI=1,#table do
--
--        local row = table[tI]
--
--        local rI = 0
--        for rI=1,#row do
--
--            if row[rI] == 1 then
--
--                hokje(i + tI - 1, j+rI - 1, color[1], color[2], color[3])
--
--            end
--
--        end
--
--    end
--
--end

shapes = {
}
shapes["J"] = {
    {1, 1, 1},
    {1, 0, 0}
}
shapes["L"] = {
    {1, 1, 1},
    {0, 0, 1}
}
shapes["T"] = {
    {1, 1, 1},
    {0, 1, 0}
}
shapes["O"] = {
    {1, 1},
    {1, 1}
}
shapes["I"] = {
    {1, 1, 1, 1}
}
shapes["Z"] = { -- Upside down, so it looks like a S but it is a Z
    { 0, 1, 1 },
    { 1, 1, 0 }
}
shapes["S"] = {
    {1, 1, 0},
    {0, 1, 1}
}

function getRandomShape()
    local names = {}
    for k,v in pairs(shapes) do
        names[#names+1] = k
    end
    return names[math.random(1, #names)]
end

function getSize(shape)
    return ivec2(#(shape[1]), #shape)
end
