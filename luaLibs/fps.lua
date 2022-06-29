Fps = {counter = 0, startTime = 0, nextTriggerTime = 0, showOutput = false, capFpsAmount=0, usleepTime=5000, printFunction=nil}

function Fps:new(printFunction)
	o = {}
	self:_resetValues()
	setmetatable(o, self)
	self.__index = self
	self.printFunction = printFunction or print
	return o
end

function Fps:togglePrint()
	if (self.showOutput) then
		self.showOutput = false
	else
		self.showOutput = true
	end
end

function Fps:setFpsCap(capFps)
	self.capFpsAmount = capFps
end

function Fps:_resetValues()
	self.startTime=extra.getTickCount()
	self.nextTriggerTime=self.startTime + 100
	self.counter = 0
end

function Fps:_trigger()
	if self.showOutput then
		self.printFunction(string.format("Fps : %d    ", self.counter))
	end
	self:_resetValues()
end

function Fps:poll()
	self.counter = self.counter + 1
	if extra.getTickCount() >= self.nextTriggerTime then
		self:_trigger()
	end

	--[[
	if self.capFpsAmount > 0 then
		-- self.counter = delta time
		--  X = 100
		local fpsProjection = (self.counter * 100) / (extra.getTickCount() - self.startTime)
		if fpsProjection == self.capFpsAmount then
		elseif fpsProjection > self.capFpsAmount then
			self.usleepTime = self.usleepTime + 500
		elseif fpsProjection < self.capFpsAmount then
			self.usleepTime = self.usleepTime - 500
		end
		extra.usleep(self.usleepTime)
	end
	--]]
end

