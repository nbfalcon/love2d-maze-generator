io.stdout:setvbuf("no")

require "maze_generator"
require "tilemapx_love"

TILES = {
    { 0, 0, 0 },
    { 255, 255, 255 },
    { 100, 100, 100 },
    { 0, 0, 255 }, -- solution
    { 255, 0, 0 }, -- start
    { 0, 255, 0 } -- end
}

function love.conf(t)
    t.title = "Maze generator"
    t.version = "0.1.0"
    t.window.setMode(600, 800, { resizable = true, highdpi = true })

    t.console = true
end

function regenerateMaze()
    maze = mazeGenerator.generateMaze(20, 20)
    mazeTilemap = mazeGenerator.maze2Tilemap(maze):copy()

    mazeSolution = mazeTilemap:copy()
    -- CONFIG: could use either; solveDFS gives a fully traced path
    --local solution = maze:solveDfs()
    local solution = maze:solveBfs()
    mazeGenerator.applySolution2Tilemap(mazeSolution, solution, 3)
    mazeSolution:set(maze.startNode.x * 2, maze.startNode.y * 2, 4)
    mazeSolution:set(maze.endNode.x * 2, maze.endNode.y * 2, 5)
end

local function tableContains(table, needle)
    for _, v in pairs(table) do
        if v == needle then
            return true
        end
    end
    return false
end

function love.load(args)
    if tableContains(args, "-debug") then
        require "mobdebug".start()
    end
    displaySolution = false
    regenerateMaze()
end

function love.draw()
    local whichTilemap
    if displaySolution then
        whichTilemap = mazeSolution
    else
        whichTilemap = mazeTilemap
    end

    local windowWidth, windowHeight = love.graphics.getDimensions()

    local cellWidth = math.floor(windowWidth / whichTilemap.width)
    local cellHeight = math.floor(windowHeight / whichTilemap.height)

    local usedWidth = cellWidth * whichTilemap.width
    local usedHeight = cellHeight * whichTilemap.height
    -- draw in center
    local x = math.floor((windowWidth - usedWidth) / 2)
    local y = math.floor((windowHeight - usedHeight) / 2)

    whichTilemap:drawRects(TILES, x, y, cellWidth, cellHeight)
end

function love.keypressed(key)
    if key == "f5" then
        regenerateMaze()
    elseif key == "s" then
        displaySolution = not displaySolution
    end
end