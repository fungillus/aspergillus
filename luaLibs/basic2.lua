
Bitmap = {core = nil}

function Bitmap:new(width, height, coreType, o)
	o = o or {}

	if coreType == nil and VIDEO_BACKEND ~= nil then
		coreType = VIDEO_BACKEND
	end

	if coreType == "braille" then
		o.core = Braille:new(width, height)
	elseif coreType == "fbdev" then
		o.core = Fbdev:new(width, height)
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

function Bitmap:setColor(r, g, b)
	return self.core:setColor(r, g, b)
end

function Bitmap:putPixel(x, y, pixel)
	return self.core:putPixel(x, y, pixel)
end

-- this shouldn't be at all
function Bitmap:setBlockColor(x, y, fgColor, bgColor)
	return self.core:setBlockColor(x, y, fgColor, bgColor)
end

function Bitmap:getBuffer()
	return self.core:getBuffer()
end

function Bitmap:renderToString()
	return self.core:renderToString()
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

function Bitmap:blit(bitmap, x, y)
	self:blitSection(bitmap, {x = x, y = y} or {x = 0, y = 0})
end

-- destinationCoordinates is a table with x and y elements.
-- sourceRectangle is a table like so : {x=nil, y=nil, width=nil, height=nil}
-- 			where nil values are expected to be actual values
-- 			if the full bitmap is to be blit, just pass nil to it.
function Bitmap:blitSection(bitmap, destinationCoordinates, sourceRectangle)
	local bitmapSize = bitmap:getSize()

	if sourceRectangle == nil then
		sourceRectangle = {x = 0, y = 0, width = bitmapSize.width, height = bitmapSize.height}
	end

	if destinationCoordinates == nil or destinationCoordinates.x == nil or destinationCoordinates.y == nil then
		print("Please input a valid destinationCoordinates table")
		return 1
	end

	if sourceRectangle.x == nil or sourceRectangle.y == nil
		or sourceRectangle.width == nil or sourceRectangle.height == nil then
		print("Source rectangle must be a table with entries : x, y, width and height")
		return 1
	end

	local height = sourceRectangle.height
	local width = sourceRectangle.width

	if sourceRectangle.height > bitmapSize.height then height = bitmapSize.height end
	if sourceRectangle.width > bitmapSize.width then width = bitmapSize.width end

	-- note that these two checks are strictly for the source bitmap, not the destination at all
	if sourceRectangle.x + sourceRectangle.width > bitmapSize.width
		or sourceRectangle.x + sourceRectangle.width < 0 then
		return 1
	end
	if sourceRectangle.y + sourceRectangle.height > bitmapSize.height
		or sourceRectangle.y + sourceRectangle.height < 0 then
		return 1
	end

	if destinationCoordinates.x + sourceRectangle.width > self.core.width then
		if destinationCoordinates.x < self.core.width then
			width = self.core.width - destinationCoordinates.x
		else
			print("Out of bound destination coordinate, horizontally.")
			return 1
		end
	end

	if destinationCoordinates.y + sourceRectangle.height > self.core.height then
		if destinationCoordinates.y < self.core.height then
			height = self.core.height - destinationCoordinates.y
		else
			print("Out of bound destination coordinate, vertically.")
			return 1
		end
	end

	if width > self.core.width then return 1 end
	if height > self.core.height then return 1 end

	local initialX = destinationCoordinates.x
	local x = 0
	local y = destinationCoordinates.y

	--print("blitSection", initialX, y, width, height, " bitmap height :", bitmapSize.height)
	for h = sourceRectangle.y, sourceRectangle.y + height - 1 do
		x = initialX
		for w = sourceRectangle.x, sourceRectangle.x + width - 1 do
			self:putPixel(x, y, bitmap:getPixel(w, h))
			x = x + 1
		end
		y = y + 1
	end

	return 0
end

function Bitmap:blitReverse(bitmap, x, y)
	local bitmapSize = bitmap:getSize()

	local initialX = x
	local pixel = 0

	for h = 0, bitmapSize.height - 1 do
		x = initialX
		for w = 0, bitmapSize.width - 1 do
			pixel = bitmap:getPixel(w, h)
			-- I think here we should skip putting the pixel if it is 0
			-- as it is now, it's only a very expensive rectangle fill.
			if pixel == 1 then
				pixel = 0
			end
			self:putPixel(x, y, pixel)
			x = x + 1
		end
		y = y + 1
	end
end

function Bitmap:isRectangleEmpty(startX, startY, width, height)
	for y = startY, height + startY do
		for x = startX, width + startX do
			if self:getPixel(x, y) ~= 0 then
				return false
			end
		end
	end
	return true
end

function Bitmap:drawBorder(borderSize)
	-- up
	for x = 0, self.core.width - 1 do
		for y = 0, borderSize - 1 do
			self:putPixel(x, y, 1)
		end
	end

	-- down
	for x = 0, self.core.width - 1 do
		for y = self.core.height - borderSize, self.core.height do
			self:putPixel(x, y, 1)
		end
	end

	-- left
	for x = 0, borderSize - 1 do
		for y = 0, self.core.height - 1 do
			self:putPixel(x, y, 1)
		end
	end

	-- right
	for x = self.core.width - borderSize, self.core.width do
		for y = 0, self.core.height - 1 do
			self:putPixel(x, y, 1)
		end
	end
end
