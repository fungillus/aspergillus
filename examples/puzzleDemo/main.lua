
function genSquare(size)
	return 	string.rep("*", size) .. "\n"
		.. string.rep("*" .. string.rep(" ", size - 2) .. "*\n", size - 2)
		.. string.rep("*", size) .. "\n"
end

function genSquare2(size, openSide)
	local squareSides = {right= "*", down= "*", left= "*", up= "*"}
	squareSides[openSide or " "] = " "
	return 	"*" .. string.rep(squareSides.up, size - 2) .. "*\n"
		.. string.rep(squareSides.left .. string.rep(" ", size - 2) .. squareSides.right .. "\n", size - 2)
		.. "*" .. string.rep(squareSides.down, size - 2) .. "*\n"
end

function genPipe(sizeX, sizeY, side)
	if side == "right" or side == "left" then
		return string.rep("*", sizeX) .. "\n"
			.. string.rep("\n", sizeY - 2)
			.. string.rep("*", sizeX) .. "\n"
	elseif side == "up" or side == "down" then
		return string.rep("*" .. string.rep(" ", sizeX - 2) .. "*\n", sizeY)
	else
		return ""
	end
end

function drawEntity(entity, positionX, positionY)
	screen:blit(entity, positionX + entity.offsetX, positionY + entity.offsetY)
end

function drawGameBoard(positionX, positionY, entities)
	for i = 0, 3 do screen:blit(square, positionX + tileSize * i, positionY) end
	for i = 0, 3 do screen:blit(square, positionX + tileSize * i, positionY + tileSize) end

	local entitiesDrawLUT = {
		one = function (side, x, y) drawEntity(userEntity[side], x, y) end
		,two = function (side, x, y) drawEntity(entity1[side], x, y) end
		,three = function (side, x, y) drawEntity(entity2[side], x, y) end
		,exit = function (side, x, y) drawEntity(exitSymbol2[side], x, y) end
	}

	local cellEntities = nil
	for y = 0, 1 do
		for x = 0, 3 do
			if entities[y + 1] then
				cellEntities = entities[y + 1][x + 1] or {}
				for i, entityType in pairs({"exit", "three", "two", "one"}) do
					local side = cellEntities[entityType]
					if side then
						local f = entitiesDrawLUT[entityType] or function() end
						f(side, positionX + tileSize * x, positionY + tileSize * y)
					end
				end
			end
		end
	end
end

function Init()
	print "\x1b[25l"
	screen = Bitmap:new(160, 100)

	fonts = Fonts:new()

	userEntity = {}
	userEntity.bmp = convertRawTextToImage([[
**
**
]])
	userEntity.bmp.offsetX = 7
	userEntity.bmp.offsetY = 7

	local sides = {"up", "right", "down", "left"}

	genSquareBitmap = function(size, side) return convertRawTextToImage(genSquare2(size, side)) end

	entity1 = {}; entity2 = {}
	for i, side in pairs(sides) do
		entity1[side] = genSquareBitmap(6, side) 
		entity1[side].offsetX = 5
		entity1[side].offsetY = 5
	end
	for i, side in pairs(sides) do
		entity2[side] = genSquareBitmap(10, side)
		entity2[side].offsetX = 3
		entity2[side].offsetY = 3
	end

	tileSize = 15

	exitSymbol2 = {}
	for i, side in pairs({"up", "down"}) do exitSymbol2[side] = convertRawTextToImage(genPipe(6, 3, side)) end
	for i, side in pairs({"right", "left"}) do exitSymbol2[side] = convertRawTextToImage(genPipe(3, 6, side)) end
	exitSymbol2.up.offsetX = math.ceil(tileSize / 2 - exitSymbol2.up.width / 2)
	exitSymbol2.up.offsetY = -math.floor(exitSymbol2.up.height / 2)

	exitSymbol2.down.offsetX = exitSymbol2.up.offsetX
	exitSymbol2.down.offsetY = math.floor(tileSize - exitSymbol2.down.height / 2 + 1)

	exitSymbol2.right.offsetX = math.floor(tileSize - exitSymbol2.right.width / 2 + 1)
	exitSymbol2.right.offsetY = math.ceil(tileSize / 2 - exitSymbol2.right.height / 2)

	exitSymbol2.left.offsetX = -math.ceil(exitSymbol2.left.width / 2 - 1)
	exitSymbol2.left.offsetY = exitSymbol2.right.offsetY


	square = genSquareBitmap(tileSize + 1)

	--[[
	screen:blit(entity2.left, 20, 4)
	screen:blit(entity1.left, 22, 6)
	screen:blit(userEntity.bmp, 24, 8)

	screen:blit(entity2.down, 5, 16)
	--]]
	
	frames = {}

	table.insert(frames, {
		{{}, {}, {}, {three = "down"}}
		,{{}, {three = "left"}, {one = "bmp"}, {two = "left"}}
	})

	table.insert(frames, {
		{{}, {}, {one = "bmp"}, {three = "down"}}
		,{{}, {three = "left"}, {}, {two = "left"}}
	})

	table.insert(frames, {
		{{}, {one = "bmp"}, {}, {three = "down"}}
		,{{}, {three = "left"}, {}, {two = "left"}}
	})

	table.insert(frames, {
		{{one = "bmp"}, {}, {}, {three = "down"}}
		,{{}, {three = "left"}, {}, {two = "left"}}
	})

	table.insert(frames, {
		{{}, {}, {}, {three = "down"}}
		,{{one = "bmp"}, {three = "left"}, {}, {two = "left"}}
	})

	table.insert(frames, {
		{{}, {}, {}, {three = "down"}}
		,{{}, {one = "bmp", three = "left"}, {}, {two = "left"}}
	})

	table.insert(frames, {
		{{}, {}, {}, {three = "down"}}
		,{{}, {}, {one = "bmp", three = "left"}, {two = "left"}}
	})

	table.insert(frames, {
		{{}, {}, {one = "bmp", three = "left"}, {three = "down"}}
		,{{}, {}, {}, {two = "left"}}
	})

	table.insert(frames, frames[1])
	specialResetFrameIndex = #frames

	table.insert(frames, {
		{{}, {}, {}, {three = "down"}}
		,{{}, {three = "left"}, {}, {one = "bmp", two = "left"}}
	})

	table.insert(frames, {
		{{}, {}, {}, {three = "down", one = "bmp", two = "left"}}
		,{{}, {three = "left"}, {}, {}}
	})

	table.insert(frames, {
		{{}, {}, {three = "down", one = "bmp", two = "left"}, {}}
		,{{}, {three = "left"}, {}, {}}
	})

	table.insert(frames, {
		{{}, {three = "down", one = "bmp", two = "left"}, {}, {}}
		,{{}, {three = "left"}, {}, {}}
	})

	table.insert(frames, {
		{{three = "down", one = "bmp", two = "left"}, {}, {}, {}}
		,{{}, {three = "left"}, {}, {}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {}}
		,{{one = "bmp", two = "left"}, {three = "left"}, {}, {}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {}}
		,{{}, {three = "left", one = "bmp", two = "left"}, {}, {}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {}}
		,{{}, {}, {three = "left", one = "bmp", two = "left"}, {}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {}}
		,{{}, {}, {}, {three = "left", one = "bmp", two = "left"}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {}}
		,{{}, {}, {one = "bmp"}, {three = "left", two = "left"}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {one = "bmp"}, {}}
		,{{}, {}, {}, {three = "left", two = "left"}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {one = "bmp"}}
		,{{}, {}, {}, {three = "left", two = "left"}}
	})

	table.insert(frames, {
		{{three = "down"}, {}, {}, {}}
		,{{}, {}, {}, {three = "left", two = "left"}}
	})

	-- set the exit tile for all frames
	for i, frame in pairs(frames) do
		frame[1][4].exit = "up"
	end

	--[[
	for i = 0, 3 do screen:blit(square, 30 + tileSize * i, 30) end
	for i = 0, 3 do screen:blit(square, 30 + tileSize * i, 30 + tileSize) end

	screen:blit(entity2.down, 30 + entity2.offset, 30 + entity2.offset)
	screen:blit(entity1.right, 30 + entity1.offset + tileSize * 2, 30 + entity1.offset)
	screen:blit(userEntity.bmp, 30 + userEntity.offset + tileSize, 30 + userEntity.offset + tileSize)
	--]]
end

function stop()
	print "\x1b[25h"
	stopGame()
end

timeoutTime = 40
currentTimeout = extra.getTickCount()

currentFrame = 1
function Poll()
	if currentTimeout <= extra.getTickCount() then
		if currentFrame == #frames then
			fonts:printText(screen, {x=40, y=18}, "Good Work!")
			stop()
		elseif currentFrame == specialResetFrameIndex then
			-- erase the text
			screen:blit(Bitmap:new(160, 30), 0, 0)
		end

		drawGameBoard(30, 30, frames[currentFrame])

		currentFrame = currentFrame + 1

		if currentFrame == specialResetFrameIndex then
			fonts:printText(screen, {x=0, y=0}, "You messed it up Chief!")
			fonts:printText(screen, {x=0, y=8}, "Time to Reset and restart")
			fonts:printText(screen, {x=0, y=16}, "all over again!")
			currentTimeout = extra.getTickCount() + timeoutTime * 10
		else
			currentTimeout = extra.getTickCount() + timeoutTime
		end
		screen:draw()
	end
end
