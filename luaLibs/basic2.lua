
Bitmap = {core = nil}

function Bitmap:new(width, height, coreType, o)
	o = o or {}

	if coreType == "braille" then
		o.core = Braille:new(width, height)
	else -- We default to the braille output
		o.core = Braille:new(width, height)
	end

	setmetatable(o, self)
	self.__index = self
	return o
end

function Bitmap:getSize()
	return {width= self.core.width, height= self.core.height}
end

function Bitmap:getRealSize()
	return {width= self.core.realWidth, height= self.core.realHeight}
end

function Bitmap:getPixel(x, y)
	return self.core:getPixel(x, y)
end

function Bitmap:putPixel(x, y, value)
	return self.core:putPixel(x, y, value)
end

function Bitmap:getBuffer()
	return self.core:getBuffer()
end

function Bitmap:blit(bitmap, x, y)
	return self.core:blit(bitmap, x, y)
end

function Bitmap:blitSection(bitmap, destinationCoordinates, sourceRectangle)
	return self.core:blitSection(bitmap, destinationCoordinates, sourceRectangle)
end

function Bitmap:blitReverse(bitmap, x, y)
	return self.core:blitReverse(bitmap, x, y)
end

function Bitmap:isRectangleEmpty(startX, startY, width, height)
	return self.core.isRectangleEmpty(startX, startY, width, height)
end

function Bitmap:draw()
	return self.core:draw()
end

function Bitmap:clear()
	return self.core:clear()
end

function Bitmap:drawBorder(borderSize)
	return self.core:drawBorder(borderSize)
end
