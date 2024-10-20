
-- this is a private core driver, it should not be used directly

require("console")

function convRawUnicodeValueToUnicode(unicodeCharacter)
	local digit1 = (unicodeCharacter & 0xf000) >> 12
	local digit2 = (unicodeCharacter & 0x0f00) >> 8
	local digit3 = (unicodeCharacter & 0x00f0) >> 4
	local digit4 = (unicodeCharacter & 0x000f)

	local b1=0xe0 + digit1

	local b2=0x80
	b2=b2 + (digit2 << 2)
	b2=b2 + ((digit3 >> 2) & 0x3)

	local b3=0x80
	b3=b3 + ((digit3 & 0x3) << 4)
	b3=b3 + digit4

	return string.format("%c%c%c", b1, b2, b3)
end

function convBrailleToRawUnicodeValue(brailleNumber)
	local digit1 = (brailleNumber & 0xf000) >> 12
	local digit2 = (brailleNumber & 0x0f00) >> 8
	local digit3 = (brailleNumber & 0x00f0) >> 4
	local digit4 = (brailleNumber & 0x000f)

	local layer1A={0x00, 0x01, 0x08, 0x09}
	local layer2A={0x00, 0x02, 0x10, 0x12}
	local layer3A={0x00, 0x04, 0x20, 0x24}
	local layer4A={0x00, 0x40, 0x80, 0xC0}

	return 0x2800 + layer1A[digit1 + 1] + layer2A[digit2 + 1] + layer3A[digit3 + 1] + layer4A[digit4 + 1]
end

function convBrailleToUnicode(brailleNumber)
	local brailleLayers = {
		{0x00, 0x01, 0x08, 0x09}
		,{0x00, 0x02, 0x10, 0x12}
		,{0x00, 0x04, 0x20, 0x24}
		,{0x00, 0x40, 0x80, 0xC0}
	}

	local baseValue = brailleLayers[1][((brailleNumber & 0xf000) >> 12) + 1]
			+ brailleLayers[2][((brailleNumber & 0x0f00) >> 8) + 1]
			+ brailleLayers[3][((brailleNumber & 0x00f0) >> 4) + 1]
			+ brailleLayers[4][(brailleNumber & 0x000f) + 1]

	local digit3 = (baseValue & 0xf0) >> 4
	local digit4 = baseValue & 0x0f

	local b2=0xa0 + ((digit3 >> 2) & 0x3)
	local b3=0x80 + ((digit3 & 0x3) << 4) + digit4

	return string.format("%c%c%c", 0xe2, b2, b3)
end

function fillLine(width, unicodeCharacter)
	local result=""
	for w=1, width do
		result = result .. convRawUnicodeValueToUnicode(unicodeCharacter)
	end

	return result
end

Braille = {width = nil, height = nil, realWidth = nil, realHeight = nil, data = nil}

function Braille:new(width, height, o)
	o = o or {}
	o.width = width
	o.height = height
	o.realWidth = math.ceil(width / 2)
	o.realHeight = math.ceil(height / 4)
	o.data = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Braille:clear()
	self.data = {}
end

-- unicode braille is like so :
--
-- this is the first empty braille character : \u2800 -> 0xe2 0xa0 0x80
-- 00
-- 00
-- 00
-- 00
--
-- \u2801 -> 0xe2 0xa0 0x81 - position (1, 1)
-- 10
-- 00
-- 00
-- 00
--
-- \u2802 -> 0xe2 0xa0 0x82 - position (1, 2)
-- 00
-- 10
-- 00
-- 00
--
-- \u2804 -> 0xe2 0xa0 0x84 - position (1, 3)
-- 00
-- 00
-- 10
-- 00
--
-- \u2840 -> 0xe2 0xa1 0x80 - position (1, 4)
-- 00
-- 00
-- 00
-- 10
--
-- \u2808 -> 0xe2 0xa0 0x88 - position (2, 1)
-- 01
-- 00
-- 00
-- 00
--
-- \u2810 -> 0xe2 0xa0 0x90 - position (2, 2)
-- 00
-- 01
-- 00
-- 00
--
-- \u2820 -> 0xe2 0xa0 0xa0 - position (2, 3)
-- 00
-- 00
-- 01
-- 00
--
-- \u2880 -> 0xe2 0xa2 0x80 - position (2, 4)
-- 00
-- 00
-- 00
-- 01

function Braille:getPixel(x, y)
	local x1=math.floor(x / 2) + 1
	local y1=math.floor(y / 4)
	local coord=x1 + (y1 * self.realWidth)
	local value=self.data[coord] or 0

	if value == 0 or value == nil then
		return 0
	end

	local convChart = { 
		 function (hdr, b1, b2) return (b2 & 0x01) == 0x01 end -- position (1, 1)
		,function (hdr, b1, b2) return (b2 & 0x08) == 0x08 end -- position (2, 1)
		,function (hdr, b1, b2) return (b2 & 0x02) == 0x02 end -- position (1, 2)
		,function (hdr, b1, b2) return (b2 & 0x10) == 0x10 end -- position (2, 2)
		,function (hdr, b1, b2) return (b2 & 0x04) == 0x04 end -- position (1, 3)
		,function (hdr, b1, b2) return (b2 & 0x20) == 0x20 end -- position (2, 3)
		,function (hdr, b1, b2) return (b1 & 0x01) == 0x01 end -- position (1, 4)
		,function (hdr, b1, b2) return (b1 & 0x02) == 0x02 end -- position (2, 4)
	}

	local convertedCoord = ((x % 2) + 1 + (y % 4) * 2)

	if convChart[convertedCoord](string.unpack("BBB", value)) then
		return 1
	else
		return 0
	end
end

function Braille:putPixel(x, y, pixel)
	local x1=math.floor(x / 2) + 1
	local y1=math.floor(y / 4)
	local coord=x1 + (y1 * self.realWidth)
	local value=self.data[coord] or 0

	if (pixel >= 1) then
		pixel = 1
	else
		pixel = 0
	end

	if (self:getPixel(x, y) == pixel) then
		return
	end

	local convChart = { 
		 function (hdr, b1, b2) return hdr, b1, b2 ~ 0x01 end -- position (1, 1)
		,function (hdr, b1, b2) return hdr, b1, b2 ~ 0x08 end -- position (2, 1)
		,function (hdr, b1, b2) return hdr, b1, b2 ~ 0x02 end -- position (1, 2)
		,function (hdr, b1, b2) return hdr, b1, b2 ~ 0x10 end -- position (2, 2)
		,function (hdr, b1, b2) return hdr, b1, b2 ~ 0x04 end -- position (1, 3)
		,function (hdr, b1, b2) return hdr, b1, b2 ~ 0x20 end -- position (2, 3)
		,function (hdr, b1, b2) return hdr, b1 ~ 0x01, b2 end -- position (1, 4)
		,function (hdr, b1, b2) return hdr, b1 ~ 0x02, b2 end -- position (2, 4)
	}

	local convertedCoord = ((x % 2) + 1 + (y % 4) * 2)
	if value ~= nil and value ~= 0 then
		self.data[coord] = string.pack("BBB", convChart[convertedCoord](string.unpack("BBB", value)))
	else
		self.data[coord] = string.pack("BBB", convChart[convertedCoord](0xe2, 0xa0, 0x80)) -- empty unicode braille character
	end
end

function Braille:marshalRowOld(rowNumber)
	local width = self.realWidth

	local result = ""
	local coord = rowNumber * width
	local blockValue = 0
	for w = 0, width - 1 do
		coord = coord + 1
		blockValue = self.data[coord]
		if blockValue == nil or blockValue == 0 then
			result = result .. " "
		else
			result = result .. convBrailleToUnicode(blockValue)
		end
	end
	return result
end

-- this version uses a technique without using string concatenation per loop
-- cycle
function Braille:marshalRow(rowNumber)
	local width = self.realWidth

	local result = {}
	local coord = rowNumber * width
	local blockValue = 0
	for w = 0, width - 1 do
		coord = coord + 1
		blockValue = self.data[coord]
		if blockValue == nil or blockValue == 0 then
			result[#result + 1] = " "
		else
			result[#result + 1] = blockValue
		end
	end
	return table.concat(result)
end

function Braille:getBuffer()
	return self.data
end

function Braille:draw()
	local height = self.realHeight

	for h = 0, height - 1 do
		console.moveCursor(1, h + 1)

		io.write(self:marshalRow(h))
	end
	io.flush()
end

function Braille:blit(bitmap, x, y)
	self:blitSection(bitmap, {x = x, y = y} or {x = 0, y = 0})
end

-- destinationCoordinates is a table with x and y elements.
-- sourceRectangle is a table like so : {x=nil, y=nil, width=nil, height=nil}
-- 			where nil values are expected to be actual values
-- 			if the full bitmap is to be blit, just pass nil to it.
function Braille:blitSection(bitmap, destinationCoordinates, sourceRectangle)
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

	if destinationCoordinates.x + sourceRectangle.width > self.width then
		if destinationCoordinates.x < self.width then
			width = self.width - destinationCoordinates.x
		else
			print("Out of bound destination coordinate, horizontally.")
			return 1
		end
	end

	if destinationCoordinates.y + sourceRectangle.height > self.height then
		if destinationCoordinates.y < self.height then
			height = self.height - destinationCoordinates.y
		else
			print("Out of bound destination coordinate, vertically.")
			return 1
		end
	end

	if width > self.width then return 1 end
	if height > self.height then return 1 end

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

function Braille:blitReverse(bitmap, x, y)
	local bitmapSize = bitmap:getSize()

	local initialX = x
	local pixel = 0

	for h = 0, bitmapSize.height - 1 do
		x = initialX
		for w = 0, bitmapSize.width - 1 do
			pixel = bitmap:getPixel(w, h)
			if pixel == 1 then
				pixel = 0
			end
			self:putPixel(x, y, pixel)
			x = x + 1
		end
		y = y + 1
	end
end

function Braille:isRectangleEmpty(startX, startY, width, height)
	for y = startY, height + startY do
		for x = startX, width + startX do
			if self:getPixel(x, y) ~= 0 then
				return false
			end
		end
	end
	return true
end

function Braille:drawBorder(borderSize)
	-- up
	for x = 0, self.width - 1 do
		for y = 0, borderSize - 1 do
			self:putPixel(x, y, 1)
		end
	end

	-- down
	for x = 0, self.width - 1 do
		for y = self.height - borderSize, self.height do
			self:putPixel(x, y, 1)
		end
	end

	-- left
	for x = 0, borderSize - 1 do
		for y = 0, self.height - 1 do
			self:putPixel(x, y, 1)
		end
	end

	-- right
	for x = self.width - borderSize, self.width do
		for y = 0, self.height - 1 do
			self:putPixel(x, y, 1)
		end
	end
end
