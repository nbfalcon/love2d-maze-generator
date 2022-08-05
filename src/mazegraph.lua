---@class mazegraph
mazegraph = {}

mazegraph.N = 'N'
mazegraph.E = 'E'
mazegraph.S = 'S'
mazegraph.W = 'W'

mazegraph.ALL_EDGES = { 'N', 'E', 'S', 'W' }

mazegraph.OPPOSITE = {
    ['N'] = 'S',
    ['E'] = 'W',
    ['S'] = 'N',
    ['W'] = 'E',
}

mazegraph.DELTA = {
    ['N'] = { x = 0, y = -1 },
    ['E'] = { x = 1, y = 0 },
    ['S'] = { x = 0, y = 1 },
    ['W'] = { x = -1, y = 0 },
}

function mazegraph:new(width, height)
    local instance = { width = width, height = height }
    setmetatable(instance, { __index = self })

    for _ = 1, height do
        row = {}
        for _ = 1, width do
            table.insert(row, {})
        end
        table.insert(instance, row)
    end

    return instance
end

function mazegraph.neighbour(x, y, edge)
    local delta = mazegraph.DELTA[edge]
    local nY = y + delta.y
    local nX = x + delta.x
    return nX, nY
end

function mazegraph:get(x, y)
    return self[y][x]
end

---@param x number
---@param y number
function mazegraph:inbounds(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function mazegraph:modEdge(x, y, edge, state)
    self[y][x][edge] = state

    -- set neighbour, if in bounds
    local nX, nY = mazegraph.neighbour(x, y, edge)
    if self:inbounds(nX, nY) then
        self[nY][nX][mazegraph.OPPOSITE[edge]] = state
    end
end

function mazegraph:addEdge(x, y, edge)
    self:modEdge(x, y, edge, true)
end

function mazegraph:removeEdge(x, y, edge)
    self:modEdge(x, y, edge, false)
end

function mazegraph:solveDfs()
    local visited = {}

    function recur(x, y)
        -- Reached goal?
        if x == self.startNode.x and y == self.startNode.y then
            return { { x = x, y = y } }
        end

        local cell = self:get(x, y)
        -- For every neighbour
        for edge, isNeighbour in pairs(cell) do
            if isNeighbour then
                local nX, nY = mazegraph.neighbour(x, y, edge)
                -- If this isn't an entry/exit edge cell where we can't go
                if self:inbounds(nX, nY) then
                    local id = nX .. ":" .. nY
                    if not visited[id] then
                        visited[id] = true

                        -- Go to the neighbour
                        local haveResult = recur(nX, nY)
                        if haveResult ~= nil then
                            -- Now we have a result to get from neighbour -> target, so append where we came from
                            table.insert(haveResult, { x = x, y = y, towards = edge })
                            return haveResult
                        end
                    end
                end
            end
        end
        return nil
    end

    -- We only add the neighbours to visited; prevent us from going back through the start node (we start at end)
    --  (sometimes yields annoying results)
    visited[self.endNode.x .. ":" .. self.endNode.y] = true

    -- we generate results in reverse; this gives us a path from startNode -> endNode that isn't reversed
    return recur(self.endNode.x, self.endNode.y)
end

local function tableReverse(tbl)
    for i = 1, math.floor(#tbl / 2) do
        local tmp = tbl[i]

        -- indices sadly start at 1, which makes everything confusing; i = 1 should swap with #tbl
        tbl[i] = tbl[#tbl - i + 1]
        tbl[#tbl - i + 1] = tmp
    end
end

function mazegraph:solveBfs()
    local predecessors = {}

    -- NOTE: We could, again, generate this thing in reverse and skip the tableReverse() call
    -- I just want something different this time.
    local queue = { self.startNode }
    local queueI = 1

    while queueI <= #queue do
        local nextNode = queue[queueI]
        queueI = queueI + 1

        if nextNode.x == self.endNode.x and nextNode.y == self.endNode.y then
            local path = {}

            -- ref comparison is safe, since we add the actual startNode
            while nextNode ~= self.startNode do
                table.insert(path, nextNode)
                local nId = nextNode.x .. ":" .. nextNode.y
                nextNode = predecessors[nId]
            end

            tableReverse(path)
            return path
        end

        for edge, isNeighbour in pairs(self:get(nextNode.x, nextNode.y)) do
            if isNeighbour then
                local nX, nY = mazegraph.neighbour(nextNode.x, nextNode.y, edge)
                if self:inbounds(nX, nY) then
                    local nId = nX .. ":" .. nY
                    -- If already visited -> our path cannot be shorter (could be equal though), since BFS is a greedy
                    --  algorithm with the invariant that we never have a sub-optimal path in predecessors
                    if not predecessors[nId] then
                        -- Our neighbour -> we came from nextNode
                        predecessors[nId] = nextNode
                        -- Also stuff it in the queue
                        table.insert(queue, { x = nX, y = nY })
                    end
                end
            end
        end
    end

    return nil -- no solution :(
end