-- enum
Direction = {up = 1, right = 2, down = 3, left = 4}

function isUp(e)
	return e == Direction.up
end

function isRight(e)
	return e == Direction.right
end

function isDown(e)
	return e == Direction.down
end

function isLeft(e)
	return e == Direction.left
end

Vector = {direction = nil, nextDirection = nil, speed = nil, nextSpeed = nil, currentCoordinate = {nil, nil}, destinationCoordinate = {nil, nil}}

function Vector:new(currentCoordinate, o)
	o = o or {}

	o.currentCoordinate = currentCoordinate

	setmetatable(o, self)
	self.__index = self
	return o
end

function Vector:getCurrentCoordinate()
	return self.currentCoordinate[1], self.currentCoordinate[2]
end

function Vector:getDestinationCoordinate()
	return self.destinationCoordinate[1], self.destinationCoordinate[2]
end

function Vector:setDestinationCoordinate(destinationCoordinate)
	self.destinationCoordinate = destinationCoordinate
end

function Vector:showDestinationCoordinate()
	print("destination coord", self:getDestinationCoordinate())
end

function Vector:showCurrentCoordinate()
	print("current coord", self:getCurrentCoordinate())
end

function Vector:_calculateNextDestinationCoordinate()
	local x, y = self:getCurrentCoordinate()

	if self.newDirection ~= nil then
		self.direction = self.newDirection
		self.newDirection = nil
	end

	if self.newSpeed ~= nil then
		self.speed = self.newSpeed
		self.newSpeed = nil
	end

	if isUp(self.direction) then
		self.destinationCoordinate = {x, y - (self.speed * 2)}
	elseif isRight(self.direction) then
		self.destinationCoordinate = {x + (self.speed * 2), y}
	elseif isDown(self.direction) then
		self.destinationCoordinate = {x, y + (self.speed * 2)}
	elseif isLeft(self.direction) then
		self.destinationCoordinate = {x - (self.speed * 2), y}
	end
end

function Vector:isReachedDestination()
	local x, y = self:getCurrentCoordinate()
	local destinationX, destinationY = self:getDestinationCoordinate()
	if isUp(self.direction) and destinationY >= y then
		return true
	elseif isRight(self.direction) and destinationX <= x then
		return true
	elseif isDown(self.direction) and destinationY <= y then
		return true
	elseif isLeft(self.direction) and destinationX >= x then
		return true
	end
	return false
end

function Vector:setMotion(direction, speed)
	--print("Setting new motion :", direction)
	if self.direction == nil and self.speed == nil then
		self.direction = direction
		self.speed = speed

		self:_calculateNextDestinationCoordinate()
	else
		self.newDirection = direction
		self.newSpeed = speed
	end
end

function Vector:_doMotion()
	local x, y = self:getCurrentCoordinate()
	if isUp(self.direction) then
		self.currentCoordinate = {x, y - self.speed}
	elseif isRight(self.direction) then
		self.currentCoordinate = {x + self.speed, y}
	elseif isDown(self.direction) then
		self.currentCoordinate = {x, y + self.speed}
	elseif isLeft(self.direction) then
		self.currentCoordinate = {x - self.speed, y}
	end
end

function Vector:poll()
	--self:showDestinationCoordinate()
	--self:showCurrentCoordinate()
	if self.direction == nil and self.speed == nil then
		return
	end

	if self:isReachedDestination() then
		self:_calculateNextDestinationCoordinate()
	else
		self:_doMotion()
	end
end
