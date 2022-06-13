
require("console")

function showUnicode(unicodeCharacter)
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

function convBrailleToUnicode(brailleNumber)
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

function fillLine(width, unicodeCharacter)
	local result=""
	for w=1, width do
		result = result .. showUnicode(unicodeCharacter)
	end

	return result
end

Bitmap = {width = 0, height = 0, realWidth = 0, realHeight = 0, data = {}}

function Bitmap:new(width, height, o)
	o = o or {}
	o.width = width
	o.height = height
	o.realWidth = math.floor(width / 2)
	o.realHeight = math.floor(height / 4)
	setmetatable(o, self)
	self.__index = self
	return o
end

function Bitmap:getPixel(x, y)
	local x1=math.floor(x / 2) + 1
	local y1=math.floor(y / 4)
	local coord=x1 + (y1 * self.realWidth)
	local value=self.data[coord] 

	if (value == nil) then
		value = 0
	end

	-- coordinate system
	--  01 23 45 67
	--0 00 00 00 00
	--1 00 00 00 00
	--2 00 00 00 00
	--3 00 00 00 00
	
	-- coord (3, 2) should give 6
	-- coord (7, 2) should give 6
	-- coord (7, 3) should give 8

	local convChart = { 
		 function (e) return (e & 0x1000) >> 12 end
		,function (e) return (e & 0x2000) >> 13 end
		,function (e) return (e & 0x0100) >> 8 end
		,function (e) return (e & 0x0200) >> 9 end
		,function (e) return (e & 0x0010) >> 4 end
		,function (e) return (e & 0x0020) >> 5 end
		,function (e) return (e & 0x0001) end
		,function (e) return (e & 0x0002) >> 1 end
	}

	local convertedCoord = ((x % 2) + 1 + (y % 4) * 2)

	return convChart[convertedCoord](value)
end

function Bitmap:putPixel(x, y, pixel)
	local x1=math.floor(x / 2) + 1
	local y1=math.floor(y / 4)
	local coord=x1 + (y1 * self.realWidth)
	local value=self.data[coord] 

	if (value == nil) then
		value = 0
	end

	if ( pixel >= 1) then
		pixel = 1
	else
		pixel = 0
	end

	if (self:getPixel(x, y) == pixel) then
		return
	end

	local convChart = { 
		  function (e) return e ~ 0x1000 end
		 ,function (e) return e ~ 0x2000 end
		 ,function (e) return e ~ 0x0100 end
		 ,function (e) return e ~ 0x0200 end
		 ,function (e) return e ~ 0x0010 end
		 ,function (e) return e ~ 0x0020 end
		 ,function (e) return e ~ 0x0001 end
		 ,function (e) return e ~ 0x0002 end
	}

	local convertedCoord = ((x % 2) + 1 + (y % 4) * 2)
	self.data[coord] = convChart[convertedCoord](value)
end

function Bitmap:show()
	local height = self.realHeight
	local width = self.realWidth

	local coord = 0
	local blockValue = 0
	local result = ""
	for h = 0, height - 1 do
		for w = 0, width - 1 do
			coord = (w + 1) + (h * width)
			blockValue = self.data[coord]
			if ( blockValue == nil ) then
				blockValue = 0
			end
			result = result .. showUnicode(convBrailleToUnicode(blockValue))
		end
		result = result .. "\n"
	end

	return result
end

function Bitmap:draw()
	local height = self.realHeight
	local width = self.realWidth

	local coord = 0
	local blockValue = 0
	for h = 0, height - 1 do
		console.moveCursor(1, h)
		for w = 0, width - 1 do
			coord = (w + 1) + (h * width)
			blockValue = self.data[coord]
			if ( blockValue == nil ) then
				blockValue = 0
			end
			io.write(showUnicode(convBrailleToUnicode(blockValue)))
		end
	end
end

function Bitmap:blit(bitmap, x, y)
	local height = bitmap.height
	local width = bitmap.width

	local initialX = x

	for h = 0, height - 1 do
		x = initialX
		for w = 0, width - 1 do
			self:putPixel(x, y, bitmap:getPixel(w, h))
			x = x + 1
		end
		y = y + 1
	end
end

function Bitmap:blitReverse(bitmap, x, y)
	local height = bitmap.height
	local width = bitmap.width

	local initialX = x
	local pixel = 0

	for h = 0, height - 1 do
		x = initialX
		for w = 0, width - 1 do
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

function Bitmap:isRectangleEmpty(startX, startY, width, height)
	for y = startY, height + startY do
		for x = startX, width + startX do
			if bitmap:getPixel(x, y) ~= 0 then
				return false
			end
		end
	end
	return true
end
