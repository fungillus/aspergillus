
Fbdev = {width = nil, height = nil, realWidth = nil, realHeight = nil, data = nil}

local function setColor(bpp, r, g, b)
	if bpp == 32 then
		return string.pack("BBBB", b, g, r, 0)
	elseif bpp == 16 then
		return string.pack("H", (r >> 3) << 11 | (g >> 2) << 5 | (b >> 3))
	else
		return 1
	end
end

function Fbdev:new(width, height, o)
	o = o or {}
	if (width == -1 or height == -1) then
		width = 1920
		height = 1080
	end
	o.width = width
	o.height = height
	o.realWidth = width
	o.realHeight = height
	o.data = {}
	o.pendings = {}
	o.bpp = 32
	--o.fbfd = io.open("/dev/fb0", "w")
	setmetatable(o, self)
	self.__index = self

	local pixel = setColor(o.bpp, 0, 0, 0)
	for c = 1, o.width * o.height do
		o.data[c] = pixel
	end

	-- detect if /dev/fb0 exists, this driver won't work without it
	-- we need to detect the bits per pixel
	-- the screen resolution
	-- the memory start address
	-- the bytes per line length
	return o
end

function Fbdev:setColor(r, g, b)
	return setColor(self.bpp, r, g, b)
end

function Fbdev:putPixel(x, y, pixel)
	local coord=x + 1 + (y * self.realWidth)

	--if (self:getPixel(x, y) == pixel) then
	--	return
	--end

	if pixel == 1 then
		pixel = self:setColor(0xAA, 0xAA, 0xAA)
	end

	self.data[coord] = pixel
	table.insert(self.pendings, {x=x, y=y, pixel=pixel})
end

function Fbdev:getPixel(x, y)
	local coord=x + 1 + (y * self.realWidth)
	local pixel = self.data[coord]

	return pixel
end

function Fbdev:setBlockColor(x, y, fgColor, bgColor)
end

function Fbdev:drawAll()
	local line
	local coord = 0
	local rows = {}
	local pixel
	local blackPixel = string.pack("BBBB", 0, 0, 0, 0)
	for y = 0, self.realHeight do
		coord = y * self.realWidth
		line = {}
		for x = 0, self.realWidth do
			pixel = self.data[x + coord]
			if pixel == nil then
				pixel = blackPixel
			end
			line[x] = pixel
		end
		rows[y] = table.concat(line)
	end
	self.fbfd:write(table.concat(rows))
end

function Fbdev:drawAll2()
	local coord
	local pixel
	for y = 0, self.realHeight do
		coord = y * self.realWidth
		for x = 0, self.realWidth do
			pixel = self.data[x + coord]
			if pixel then
				self.fbfd:seek("set", (x * 4) + (coord * 4))
				self.fbfd:write(pixel)
			end
		end
	end
end

function Fbdev:drawAll3()
	local fbfd = io.open("/dev/fb0", "w")
	fbfd:write(table.concat(self.data))
	fbfd:close()
end

function Fbdev:drawPending()
	local fbfd = io.open("/dev/fb0", "w")
	local i, pending
	for i = 1, #self.pendings do
		pending = self.pendings[i]
		fbfd:seek("set", (pending.x * 4) + (pending.y * self.realWidth * 4))
		fbfd:write(pending.pixel)
	end
	fbfd:close()
end

function Fbdev:draw()
	--self:drawAll()
	--self:drawAll2()
	self:drawAll3()
	--self:drawPending()
	self.pendings = {}
end

function Fbdev:clear()
	self.data = {}
end
