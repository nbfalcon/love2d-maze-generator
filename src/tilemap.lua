---@class tilemap
tilemap = {}

function tilemap:new(width, height, fill)
    local instance = { width = width, height = height }
    setmetatable(instance, { __index = self })

    for _ = 1, height do
        local row = {}
        for _ = 1, width do
            table.insert(row, fill)
        end
        table.insert(instance, row)
    end

    return instance
end

--- @return tilemap
function tilemap:copy()
    local instance = { width = self.width, height = self.height }
    setmetatable(instance, getmetatable(self))

    for y = 1, self.height do
        local row = {}
        for x = 1, self.width do
            table.insert(row, self:get(x, y))
        end
        table.insert(instance, row)
    end

    return instance
end

function tilemap:set(x, y, value)
    self[y][x] = value
end

function tilemap:get(x, y)
    return self[y][x]
end