require "mazegraph"
require "tilemap"

mazeGenerator = {}

---@param maze mazegraph
local function randomPrim(maze, startNode)
    local visitQueue = { startNode }
    local alreadyVisited = {}

    while #visitQueue > 0 do
        local nextVisitI = math.random(1, #visitQueue)
        local nextVisit = visitQueue[nextVisitI]
        visitQueue[nextVisitI] = visitQueue[#visitQueue]
        visitQueue[#visitQueue] = nil

        local x, y = nextVisit.x, nextVisit.y
        local id = x .. ":" .. y
        if not alreadyVisited[id] then
            alreadyVisited[id] = true

            maze:addEdge(x, y, nextVisit.comeFrom)
            for _, edge in ipairs(mazegraph.ALL_EDGES) do
                local nX, nY = mazegraph.neighbour(x, y, edge)
                if maze:inbounds(nX, nY) then
                    table.insert(visitQueue, { x = nX, y = nY, comeFrom = mazegraph.OPPOSITE[edge] })
                end
            end
        end
    end
end

function mazeGenerator.generateMaze(width, height)
    local maze = mazegraph:new(width, height)

    local startNorthX = math.random(1, width)
    local endSouthX = math.random(1, width)

    local startNode = { x = startNorthX, y = 1, comeFrom = mazegraph.N }
    local endNode = { x = endSouthX, y = height, comeFrom = mazegraph.S }

    maze:addEdge(endSouthX, height, mazegraph.S)
    randomPrim(maze, startNode)

    maze.startNode = startNode
    maze.endNode = endNode

    return maze
end


-- FIXME: should this go in mazegraph?
---@param maze mazegraph
function mazeGenerator.maze2Tilemap(maze)
    local resultTilemap = tilemap:new(maze.width * 2 + 1, maze.height * 2 + 1, 0)

    for y = 1, maze.height do
        for x = 1, maze.width do
            resultTilemap:set(x * 2, y * 2, 1)

            local me = maze:get(x, y)
            for edge, isNeighbour in pairs(me) do
                if isNeighbour then
                    resultTilemap:set(x * 2 + mazegraph.DELTA[edge].x, y * 2 + mazegraph.DELTA[edge].y, 2)
                end
            end
        end
    end

    return resultTilemap
end

---@param target tilemap
function mazeGenerator.applySolution2Tilemap(target, coords, value)
    for _, xy in ipairs(coords) do
        print("x: " .. xy.x .. ", " .. "y: " .. xy.y)
        target:set(xy.x * 2, xy.y * 2, value)

        if xy.towards then
            local tX, tY = mazegraph.neighbour(xy.x * 2, xy.y * 2, xy.towards)
            target:set(tX, tY, value)
        end
    end
end