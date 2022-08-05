function tilemap:drawRects(tileColors, offsetX, offsetY, cellWidth, cellHeight)
    for y = 1, self.height do
        for x = 1, self.width do
            love.graphics.setColor(tileColors[self:get(x, y) + 1])
            love.graphics.rectangle("fill",
                    offsetX + (x - 1) * cellWidth,
                    offsetY + (y - 1) * cellHeight,
                    cellWidth, cellHeight)
        end
    end
end