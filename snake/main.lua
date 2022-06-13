
require("basic2")
require("vector")
require("fps")
require("console")

function calcDistance(coord1, coord2)
	-- this is the real formula
	--return math.floor(math.sqrt((coord2[1] - coord1[1])^2 + (coord2[2] - coord1[2])^2))
	--return math.ceil(math.sqrt((coord2[1] - coord1[1])^2 + (coord2[2] - coord1[2])^2))
	-- we need something lighter though (although way less precise):
	--return math.max(math.abs(coord2[1] - coord1[1]), math.abs(coord2[2] - coord1[2]))
	return math.abs(coord2[1] - coord1[1]) + math.abs(coord2[2] - coord1[2])
end

Apple = {bitmapParent = nil, bitmap = nil, position = {}}

function Apple:new(bitmapParent, positionX, positionY, o)
	o = o or {}

	o.bitmapParent = bitmapParent

	o.position = {positionX, positionY}
	o.bitmap = Bitmap:new(4, 4)

	--    
	-- ** 
	-- ** 
	--    
	o.bitmap.data = {
		0x0220, 0x0110
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

function Apple:draw()
	self.bitmapParent:blit(self.bitmap, self.position[1], self.position[2])
end

function Apple:getCollisionCoordinates()
	local x, y = self.position[1] + 1, self.position[2] + 1
	return {
		{x, y}
		,{x + 1, y}
		,{x, y + 1}
		,{x + 1, y + 1}
	}
end

function Apple:destroy()
	--print("destroying apple : ", self.position[1], self.position[2])
	self.bitmapParent:blitReverse(self.bitmap, self.position[1], self.position[2])
end

Apples = {appleList = {}, appleCollisionMap = {}, boundingBox = {0, 0, 1, 1}}

function Apples:new(bitmapParent, o)
	o = o or {}
	o.bitmapParent = bitmapParent

	o.appleCollisionMap = {}
	for i = 1, bitmapParent.height do
		o.appleCollisionMap[i] = {}
	end

	setmetatable(o, self)
	self.__index = self
	return o
end

function Apples:setBoundingBox(startX, startY, width, height)
	self.boundingBox = {startX, startY, width, height}
end

function isRectangleBitmapPositionEmpty(bitmap, startX, startY, width, height)
	for y = startY, height + startY do
		for x = startX, width + startX do
			if bitmap:getPixel(x, y) ~= 0 then
				return 0
			end
		end
	end
	return 1
end

function hashCoordinateTable(coordinateTable)
	return string.format("%d %d", coordinateTable[1], coordinateTable[2])
end

function Apples:setCollisionMapEntries(entries, value)
	for i = 1, #entries do
		--print(entries[i][1], entries[i][2])
		--self.appleCollisionMap[hashCoordinateTable(entries[i])] = value
		self.appleCollisionMap[entries[i][2]][entries[i][1]] = value
	end
end

function Apples:createAppleAtPosition(positionX, positionY)
	local newApple = Apple:new(self.bitmapParent, positionX, positionY)
	local newAppleId = #self.appleList + 1

	self.appleList[newAppleId] = newApple
	newApple:draw()

	self:setCollisionMapEntries(newApple:getCollisionCoordinates(), newAppleId)

	--print("Added apple : ", newAppleId)
end

function Apples:createAppleRandomPosition()
	local randomXPosition, randomYPosition = 0, 0
	while true do
		randomXPosition = math.random(self.boundingBox[1], self.boundingBox[3])
		randomYPosition = math.random(self.boundingBox[2], self.boundingBox[4])
		
		if self.bitmapParent:isRectangleEmpty(randomXPosition, randomYPosition, 4, 4) == true then
			break
		end
	end
	self:createAppleAtPosition(randomXPosition, randomYPosition)
end

function Apples:isAppleAtPosition(posX, posY)
	--local result = self.appleCollisionMap[string.format("%d %d", posX, posY)]
	local result = self.appleCollisionMap[posY][posX]
	return result ~= nil
end

function Apples:deleteAppleAtPosition(posX, posY)
	--local appleId = self.appleCollisionMap[string.format("%d %d", posX, posY)]
	local appleId = self.appleCollisionMap[posY + 1][posX + 1]
	if appleId ~= nil then
		self:deleteApple(appleId)

		--print("Deleted apple : ", appleId)
	end
end

function Apples:deleteApple(appleId)
	local currentApple = self.appleList[appleId]
	if currentApple ~= nil then
		currentApple:destroy()
		self:setCollisionMapEntries(currentApple:getCollisionCoordinates(), nil)
		self.appleList[appleId] = nil
	end
end

Snake = { speed = 2, size = 0 }

function Snake:new(bitmap, startX, startY, o)
	o = o or {}

	o.vector = Vector:new({startX, startY})

	o.bitmapParent = bitmap

	o.bitmap = Bitmap:new(4, 4)
	-- **
	--****
	--****
	-- ** 
	o.bitmap.data = {
		0x2332, 0x1331
	}

	o.tails = {}

	o.apples = nil

	setmetatable(o, self)
	self.__index = self
	return o
end

function Snake:setApples(apples)
	self.apples = apples
end

function Snake:_draw()
	local x, y = self.vector:getCurrentCoordinate()
	self.bitmapParent:blit(self.bitmap, x, y)

	--local tailX, tailY = 0, 0
	--for i = 1, self.size do
	--	tailX, tailY = self.tails[i]:getCurrentCoordinate()
	--end
	--if self.size > 0 then
	--	self.bitmapParent:blit(self.bitmap, tailX, tailY)
	--end
end

function Snake:_pollTails()
	local parentX, parentY = self.vector:getCurrentCoordinate()
	for i = 1, self.size do
		local currentX, currentY = self.tails[i]:getCurrentCoordinate()
		local currentDistance = calcDistance({parentX, parentY}, {self.tails[i]:getCurrentCoordinate()})

		if currentDistance >= 4 then
			if self.tails[i]:isReachedDestination() then
				self:_setTailsMotion(i, self.tails[i].direction, self.vector.speed)
			end
			self.tails[i]:poll()
			parentX, parentY = currentX, currentY
		end
	end
end

function Snake:growIfTouchAnApple()
	if self.apples ~= nil then
		local posX, posY = self.vector:getCurrentCoordinate()
		--print("position : ", posX, posY, self.apples:isAppleAtPosition(posX, posY))
		if self.apples:isAppleAtPosition(self.vector:getCurrentCoordinate())
			or self.apples:isAppleAtPosition(posX, posY + 2) then
			self:addTail()
			self.apples:deleteAppleAtPosition(self.vector:getCurrentCoordinate())
			self.apples:deleteAppleAtPosition(posX, posY + 2)
		end
	end
end

function Snake:poll()
	self:clearDraw()
	self:growIfTouchAnApple()
	self.vector:poll()
	self:_pollTails()
	self:_draw()
end

function Snake:addTail()
	local previousLastTail
	if self.size > 0 then
		previousLastTail = self.tails[self.size]
	else
		previousLastTail = self.vector
	end
	self.size = self.size + 1

	--self.tails[self.size] = Vector:new({self.vector:getCurrentCoordinate()})
	--self.tails[self.size]:setMotion(self.vector.direction, self.vector.speed)
	self.tails[self.size] = Vector:new({previousLastTail:getCurrentCoordinate()})
	self.tails[self.size]:setMotion(previousLastTail.direction, previousLastTail.speed)
end

function Snake:clearDraw()
	--local x, y = self.vector:getCurrentCoordinate()
	--self.bitmapParent:blitReverse(self.bitmap, x, y)

	local tailX, tailY = 0, 0
	--[[
	for i = 1, self.size do
		tailX, tailY = self.tails[i]:getCurrentCoordinate()
		--self.bitmapParent:blitReverse(self.bitmap, tailX, tailY)
	end
	--]]

	if (self.size > 0) then
		tailX, tailY = self.tails[#self.tails]:getCurrentCoordinate()
		self.bitmapParent:blitReverse(self.bitmap, tailX, tailY)
	end
end

function Snake:_setTailsMotion(num, direction, speed)
	local previousDirection, previousSpeed = direction, speed
	local destinationX, destinationY = self.vector:getDestinationCoordinate()

	if (num == 0) then
		destinationX, destinationY = self.vector:getDestinationCoordinate()
	else
		destinationX, destinationY = self.tails[num]:getDestinationCoordinate()
	end

	for i = num + 1, self.size do
		local currentDirection, currentSpeed = self.tails[i].direction, self.tails[i].speed

		self.tails[i]:setDestinationCoordinate({destinationX, destinationY})

		destinationX, destinationY = self.tails[i]:getCurrentCoordinate()
		self.tails[i]:setMotion(previousDirection, previousSpeed)

		previousDirection, previousSpeed = currentDirection, currentSpeed
	end
end

function Snake:moveLeft()
	if self.direction ~= Direction.right then
		self.vector:setMotion(Direction.left, self.speed)
		self:_setTailsMotion(0, Direction.left, self.speed)
	end
end

function Snake:moveRight()
	if self.direction ~= Direction.left then
		self.vector:setMotion(Direction.right, self.speed)
		self:_setTailsMotion(0, Direction.right, self.speed)
	end
end

function Snake:moveDown()
	if self.direction ~= Direction.up then
		self.vector:setMotion(Direction.down, self.speed)
		self:_setTailsMotion(0, Direction.down, self.speed)
	end
end

function Snake:moveUp()
	if self.direction ~= Direction.down then
		self.vector:setMotion(Direction.up, self.speed)
		self:_setTailsMotion(0, Direction.up, self.speed)
	end
end

local gameState = {
	bitmap = nil
	,snake = nil
	,apples = nil
	,fps = nil
}

function Init()
	print "\x1b[25l"

	bitmap = Bitmap:new(100, 100)

	snake = Snake:new(bitmap, 80, 50)
	snake:addTail()

	apples = Apples:new(bitmap)
	apples:setBoundingBox(5, 5, 95, 95)
	snake:setApples(apples)

	apples:createAppleAtPosition(55, 50)
	apples:createAppleAtPosition(52, 66)

	console.resetScreen()
	bitmap:draw()

	bitmap:draw()

	fps = Fps:new()
	fps:togglePrint()
	fps:setFpsCap(30)

	gameState.bitmap = bitmap
	gameState.snake = snake
	gameState.apples = apples
	gameState.fps = fps
end

function gameFrame(tick)
	if tick == 0 then
		gameState.snake:moveLeft()
	elseif tick == 35 then
		gameState.snake:moveUp()
	elseif tick == 45 then
		gameState.snake:moveRight()
	elseif tick == 85 then
		gameState.snake:moveDown()
	elseif tick == 110 then
		gameState.snake:moveLeft()
	elseif tick == 145 then
		gameState.snake:moveDown()
	elseif tick == 165 then
		gameState.snake:moveRight()
	elseif tick == 190 then
		gameState.snake:moveUp()
	elseif tick == 205 then
		gameState.snake:moveRight()
	elseif tick == 225 then
		gameState.snake:moveUp()
	elseif tick == 245 then
		gameState.snake:moveLeft()
	end

	gameState.snake:poll()
	gameState.bitmap:draw()
	--gameState.fps:poll()
end

function Exit()
	print "\x1b[25h"
	stopGame()
end

i = 0

function Poll()
	if i == 255 then
		Exit()
	else
		gameFrame(i)
		i = i + 1
	end
end
