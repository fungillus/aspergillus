Animate = {}

function Animate:new(animateTable, interFrameTimeout, position, startTime, o)
	o = o or {}

	o.animateBitmaps = {}
	o.totalFrames = #animateTable

	local i
	for i = 1, o.totalFrames do
		o.animateBitmaps[i] = animateTable[i]
	end
	o.interFrameTimeout = interFrameTimeout
	o.position= {x = position.x, y = position.y}

	o.startTime = startTime or extra.getTickCount()

	o._isStarted = false
	o._isJustStarted = false

	setmetatable(o, self)
	self.__index = self

	self:reset()
	return o
end

function Animate:isStarted()
	if self._isStarted then
		return true
	elseif extra.getTickCount() >= self.startTime then
		self._isStarted = true
		self._isJustStarted = true
		self.ticksForNextFrame = extra.getTickCount() + self.interFrameTimeout
		return true
	else
		return false
	end
end

function Animate:reset()
	self.currentFrameIndex = 1
	self.ticksForNextFrame = extra.getTickCount()
end

function Animate:_nextFrame()
	self.currentFrameIndex = self.currentFrameIndex + 1
	self.ticksForNextFrame = extra.getTickCount() + self.interFrameTimeout
end

-- returns true if the frame changed
function Animate:poll()
	if self.currentFrameIndex <= self.totalFrames then
		if self:isStarted() then
			if extra.getTickCount() >= self.ticksForNextFrame then
				self:_nextFrame()
				return true
			elseif self._isJustStarted then
				self._isJustStarted = false
				return true
			end
		end
	end
	return false
end

function Animate:getCurrentFrame()
	if self:isStarted() and self.currentFrameIndex <= self.totalFrames then
		return self.animateBitmaps[self.currentFrameIndex]
	else
		return nil
	end
end

function Animate:getPreviousFrame()
	if self:isStarted() and self.currentFrameIndex > 1 then
		return self.animateBitmaps[self.currentFrameIndex - 1]
	else
		return nil
	end
end

function Animate:getPosition()
	return self.position
end

function drawAnimationsOnScreen(animations, screen)
	for i = 1, #animations do
		if animations[i]:poll() then
			local previousFrame = animations[i]:getPreviousFrame()
			local currentFrame = animations[i]:getCurrentFrame()
			local position = animations[i]:getPosition()
			if previousFrame then
				screen:blitReverse(previousFrame, position.x, position.y)
			end
			if currentFrame then
				screen:blit(currentFrame, position.x, position.y)
			end

			screen:draw()
		end
	end
end
