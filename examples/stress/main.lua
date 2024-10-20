-- Bresenham's line algorithm taken from wikipedia
local function plotLineLow(bmp, x0, y0, x1, y1)
	local dx = x1 - x0
	local dy = y1 - y0
	local yi = 1

	if dy < 0 then
		yi = -1
		dy = -dy
	end

	local d = (2 * dy) - dx
	local y = y0

	for x = x0, x1 do
		bmp:putPixel(x, y, 1)
		if d > 0 then
			y = y + yi
			d = d + (2 * (dy - dx))
		else
			d = d + (2 * dy)
		end
	end
end

local function plotLineHigh(bmp, x0, y0, x1, y1)
	local dx = x1 - x0
	local dy = y1 - y0
	local xi = 1

	if dx < 0 then
		xi = -1
		dx = -dx
	end

	local d = (2 * dx) - dy
	local x = x0

	for y = y0, y1 do
		bmp:putPixel(x, y, 1)
		if d > 0 then
			x = x + xi
			d = d + (2 * (dx - dy))
		else
			d = d + (2 * dx)
		end
	end
end

function plotLine(bmp, x0, y0, x1, y1)
	if math.abs(y1 - y0) < math.abs(x1 - x0) then
		if x0 > x1 then
			plotLineLow(bmp, x1, y1, x0, y0)
		else
			plotLineLow(bmp, x0, y0, x1, y1)
		end
	else
		if y0 > y1 then
			plotLineHigh(bmp, x1, y1, x0, y0)
		else
			plotLineHigh(bmp, x0, y0, x1, y1)
		end
	end
end

function Init()
	local screenCol, screenRow = extra.getConsoleSize()
	local screenWidth = screenCol * 2 - 1
	local screenHeight = screenRow * 4 - 1
	local bmp = Bitmap:new(screenWidth + 1, screenHeight + 1)
	--local fonts = Fonts:new()

	console.clearScreen()

	-- horizontal lines
	for y = 0, screenHeight, 8 do
		plotLine(bmp, 0, y, screenWidth, y)
		bmp:draw()
	end

	-- vertical lines
	for x = 0, screenWidth, 8 do
		plotLine(bmp, x, 0, x, screenHeight)
		bmp:draw()
	end

	-- diagonal lines
	for i = 0, screenHeight, 4 do
		plotLine(bmp, 0, i, math.abs(screenWidth - (i * 2)), screenHeight)
		bmp:draw()
	end

	-- a sin wave
	for x = 0, screenWidth do
		y = math.ceil((math.sin(x / 10) + 2) * 10)
		bmp:putPixel(x, y, 1)
		bmp:draw()
	end
end

function Poll()
	stopGame()
end
