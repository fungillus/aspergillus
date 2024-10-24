
-- this is a private core driver, it should not be used directly

require("console")
require("extra")

Braille = {width = nil, height = nil, realWidth = nil, realHeight = nil, data = nil}

function Braille:new(width, height, o)
	o = o or {}
	if (width == -1 or height == -1) then
		width, height = extra.getConsoleSize()
		width = width * 2
		height = height * 4
	end
	o.width = width
	o.height = height
	o.realWidth = math.ceil(width / 2)
	o.realHeight = math.ceil(height / 4)
	o.data = {}
	o.pendings = {}
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

function blockValuePack1(fgColor, bgColor, header, b1, b2)
	return string.pack("BBB", header, b1, b2)
end

-- defaults
-- fgColor : 188 (gray)
-- bgColor : 16 (black)
function blockValuePack(fgColor, bgColor, header, b1, b2)
	return string.pack("BBBBBBBc3BBBBBBBBc3BBBBBBBB"
		-- the foreground color
		,0x1b
		,0x5b -- [
		,0x33 -- 3
		,0x38 -- 8
		,0x3b -- ;
		,0x35 -- 5
		,0x3b -- ;
		,string.format("%.3d", fgColor)
		,0x6d -- m
		-- the background color
		,0x1b
		,0x5b -- [
		,0x34 -- 4
		,0x38 -- 8
		,0x3b -- ;
		,0x35 -- 5
		,0x3b -- ;
		,string.format("%.3d", bgColor)
		,0x6d -- m
		-- the value of the block
		,header
		,b1
		,b2
		-- ansi escape reset
		,0x1b
		,0x5b -- [
		,0x30 -- 0
		,0x6d -- m
		)
end

function blockValueUnpack(value)
	local _, fgColor, _, _, bgColor, _, header, b1, b2 = string.unpack("c7c3Bc7c3BBBB", value)
	return fgColor, bgColor, header, b1, b2
end

function blockValueUnpackValue(value)
	local _, header, b1, b2 = string.unpack("c22BBB", value)
	return header, b1, b2
	
	--local header, b1, b2 = string.unpack("BBB", value)
	--return header, b1, b2
end

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

	--if convChart[convertedCoord](string.unpack("BBB", value)) then
	if convChart[convertedCoord](blockValueUnpackValue(value)) then
		return 1
	else
		return 0
	end
end

function Braille:setBlockColor(x, y, fgColor, bgColor)
	local x1=math.floor(x / 2) + 1
	local y1=math.floor(y / 4)
	local coord=x1 + (y1 * self.realWidth)
	local value=self.data[coord] or 0

	if value ~= nil and value ~= 0 then
		self.data[coord] = blockValuePack(fgColor, bgColor, blockValueUnpackValue(value))
	else
		self.data[coord] = blockValuePack(fgColor, bgColor, 0xe2, 0xa0, 0x80)
	end
	table.insert(self.pendings, {x=x1, y=y1, pixel=self.data[coord]})
end

function Braille:setColor(r, g, b)
	return 1
end

-- FIXME validate the coordinate
function Braille:putPixel(x, y, pixel)
	local x1=math.floor(x / 2) + 1
	local y1=math.floor(y / 4)
	local coord=x1 + (y1 * self.realWidth)
	local value=self.data[coord] or 0
	local fgColor = 188 -- gray
	local bgColor = 16 -- black

	if not pixel then
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

	local innerCoord = ((x % 2) + 1 + (y % 4) * 2)
	if value ~= nil and value ~= 0 then
		--self.data[coord] = string.pack("BBB", convChart[innerCoord](string.unpack("BBB", value)))
		self.data[coord] = blockValuePack(fgColor, bgColor, convChart[innerCoord](blockValueUnpackValue(value)))
	else
		--self.data[coord] = string.pack("BBB", convChart[innerCoord](0xe2, 0xa0, 0x80)) -- empty unicode braille character
		self.data[coord] = blockValuePack(fgColor, bgColor, convChart[innerCoord](0xe2, 0xa0, 0x80))
	end
	table.insert(self.pendings, {x=x1, y=y1, pixel=self.data[coord]})
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
	--return console.foregroundColor(255, 0, 0, table.concat(result))
end

function Braille:getBuffer()
	return self.data
end

function Braille:renderToString()
	local height = self.realHeight
	local result = ""

	for h = 0, height - 1 do
		result = result .. self:marshalRow(h) .. "\n"
	end

	return result
end

function Braille:drawAll()
	local height = self.realHeight

	for h = 0, height - 1 do
		console.moveCursor(1, h + 1)

		io.write(self:marshalRow(h))
	end
	io.flush()
end

function Braille:drawPending()
	local i, pending
	for i = 1, #self.pendings do
		pending = self.pendings[i]
		console.moveCursor(pending.x, pending.y + 1)
		io.write(pending.pixel)
	end
	console.moveCursor(self.realWidth, self.realHeight)
	self.pendings = {}
	io.flush()
end

-- redraw only rows that have changes, only once per row
function Braille:drawPendingHybrid()
	local doneRows = {}
	local i, pending
	for i = 1, #self.pendings do
		pending = self.pendings[i]
		if doneRows[pending.y] == nil then
			doneRows[pending.y] = 1
			console.moveCursor(1, pending.y)
			io.write(self:marshalRow(pending.y))
		end
	end
	console.moveCursor(self.realWidth, self.realHeight)
	self.pendings = {}
	io.flush()
end

function Braille:draw()
	self:drawPending()
	--self:drawPendingHybrid()
	--self:drawAll()
end
