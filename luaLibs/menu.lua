
require("basic2")
require("fonts")

require("convertImage")

Menu = {drawContext = nil, entries = nil, drawBitmaps = nil, currentPage = nil, coordinate = nil, arrowBitmaps = nil, alignment = nil, buttonPressTimeout = nil, buttonTimeouts = nil}

function Menu:new(drawContext, coordinate, menuEntries, o)
	o = o or {}
	o.drawContext = {screen=drawContext.screen, fonts=drawContext.fonts or Fonts:new()}
	o.entries = menuEntries or {}
	o.drawnMenuObjects = {}
	o.coordinate = {x = coordinate.x, y = coordinate.y} or {x = 0, y = 0}
	o.currentPage = 0
	o.alignment = "left"
	o.buttonsPressTimeout = 20
	o.buttonsPressNextTimeout = {}
	o.arrowBitmaps = {}

	o.arrowBitmaps.up = convertRawTextToImage([[
   *
  ***
 *****
*******
  ***
  ***
]])

	o.arrowBitmaps.down = convertRawTextToImage([[
  ***
  ***
*******
 *****
  ***
   *
]])

	o.arrowBitmaps.right = convertRawTextToImage([[
  *
  **
*****
******
*****
  **
  *
]])

	o.arrowBitmaps.left = convertRawTextToImage([[
   *
  **
 *****
******
 *****
  **
   *
]])

	setmetatable(o, self)
	self.__index = self
	return o
end

function Menu:clean()
	if #self.drawnMenuObjects > 0 then
		for i, drawnMenuObject in pairs(self.drawnMenuObjects) do
			self.drawContext.screen:blitReverse(drawnMenuObject.bitmap, drawnMenuObject.coordinate.x, drawnMenuObject.coordinate.y)
		end

		self.drawnMenuObjects = {}
	end
end

function Menu:draw()
	if #self.drawnMenuObjects > 0 then
		self:clean()
	end

	self:_populateMenuEntries()
	for i, drawnMenuObject in pairs(self.drawnMenuObjects) do
		self.drawContext.screen:blit(drawnMenuObject.bitmap, drawnMenuObject.coordinate.x, drawnMenuObject.coordinate.y)
	end

	self.drawContext.screen:draw()
end

function Menu:_populateMenuEntries()
	local currentEntry = nil
	local entryImg = nil
	local baseBorderSize = 1
	local borderSize = nil
	local baseCoordinates = {x = self.coordinate.x, y = self.coordinate.y}
	local maxXCoordinate = 0
	local calculatedXCoordinate = 0

	local isFirst = true
	local alignment = self.alignment
	for entryIndex, currentEntry in pairs(self.entries) do
		if currentEntry.selected == true then
			borderSize = baseBorderSize + 1
		else
			borderSize = baseBorderSize
		end
		if currentEntry.type == "button" then
			entryImg = _createButton(self.drawContext.fonts, {drawBorder = true, borderSize = borderSize}, currentEntry.name)

			if isFirst then
				baseCoordinates.x = giveMiddlePoint(self.drawContext.screen, entryImg)
				maxXCoordinate = baseCoordinates.x + entryImg.width
			end

			calculatedXCoordinate = alignmentCalculation(self.drawContext.screen, entryImg, baseCoordinates.x, maxXCoordinate, alignment)

			table.insert(self.drawnMenuObjects, {bitmap = entryImg, coordinate = {x = calculatedXCoordinate, y = baseCoordinates.y}})

			baseCoordinates.y = baseCoordinates.y + entryImg.height + 2

			if isFirst then
				isFirst = false
			end
		end
	end
end

function Menu:alignCenter()
	self.alignment = "centered"
end

function Menu:alignLeft()
	self.alignment = "left"
end

function Menu:alignRight()
	self.alignment = "right"
end

function _createButton(fonts, config, text)
	config = config or {}

	if config.drawBorder == nil then
		config.drawBorder = false
	end

	if config.borderSize == nil then
		config.borderSize = 1
	end

	local width = fonts:getCharacterWidth() * #text
	local height = fonts:getCharacterHeight()

	local textStartX = 0
	local textStartY = 0

	if config.drawBorder then
		height = height + (config.borderSize * 2) + 2

		width = width + (config.borderSize * 2) + 4

		textStartX = config.borderSize + 2
		textStartY = config.borderSize + 2
	end

	local bitmap = Bitmap:new(width, height)

	fonts:printText(bitmap, {x=textStartX, y=textStartY}, text)

	if config.drawBorder then
		bitmap:drawBorder(config.borderSize)
	end

	return bitmap
end

function giveMiddlePoint(primaryBitmap, secondaryBitmap)
	return (primaryBitmap.width / 2) - (secondaryBitmap.width / 2)
end

-- alignment is : centered, left or right
function alignmentCalculation(screen, image, baseXCoordinate, maxXCoordinate, alignment)
	local result = 0
	if alignment == "centered" then
		result = giveMiddlePoint(screen, image)
	elseif alignment == "left" then
		result = baseXCoordinate
	elseif alignment == "right" then
		-- the goal is : baseXCoordinate + x + image.width == maxXCoordinate
		-- 		 x = maxXCoordinate - (baseXCoordinate + image.width)
		result = baseXCoordinate + (maxXCoordinate - (baseXCoordinate + image.width))
	else
		result = alignmentCalculation(screen, image, "left")
	end

	return result
end

function Menu:selectNext()
	local mustSelectNext = false
	for entryIndex in pairs(self.entries) do
		if mustSelectNext == true then
			self.entries[entryIndex].selected = true
			break
		end
		if self.entries[entryIndex].selected == true then
			if entryIndex == #self.entries then -- can't go beyond the last entry element
				break
			end
			self.entries[entryIndex].selected = nil
			mustSelectNext = true
		end
	end
	self:draw()
end

function Menu:selectPrevious()
	local mustSelectNext = false
	for entryIndex = #self.entries, 0, -1 do
		if mustSelectNext == true then
			self.entries[entryIndex].selected = true
			break
		end
		if self.entries[entryIndex].selected == true then
			if entryIndex <= 1 then -- can't go before the first entry element
				break
			end
			self.entries[entryIndex].selected = nil
			mustSelectNext = true
		end
	end

	self:draw()
end

function Menu:trigger()
	for entryIndex, entry in pairs(self.entries) do
		if entry.selected == true then
			if entry.onTrigger ~= nil then
				entry.onTrigger()
			end
		end
	end
end

function handleTimeout(tbl, name, timeout)
	--print("handleTimeout", name)
	if tbl[name] ~= nil then
		if tbl[name] <= extra.getTickCount() then
			--print("handleTimeout", "done", tbl[name])
			tbl[name] = nil
			return true
		end
	else
		tbl[name] = extra.getTickCount() + timeout
		return true
	end
	return false
end

function Menu:handleInputs()
	local currentButtons = getButtonState()

	if currentButtons & buttons.kButtonLeft == buttons.kButtonLeft then
		return
	elseif currentButtons & buttons.kButtonRight == buttons.kButtonRight then
		return
	elseif currentButtons & buttons.kButtonUp == buttons.kButtonUp then
		if handleTimeout(self.buttonsPressNextTimeout, "buttonUp", self.buttonsPressTimeout) then
			self:selectPrevious()
		end
	elseif currentButtons & buttons.kButtonDown == buttons.kButtonDown then
		if handleTimeout(self.buttonsPressNextTimeout, "buttonDown", self.buttonsPressTimeout) then
			self:selectNext()
		end
	elseif currentButtons & buttons.kButtonA == buttons.kButtonA then
		if handleTimeout(self.buttonsPressNextTimeout, "buttonA", self.buttonsPressTimeout + 100) then
			self:trigger()
		end
	end
end
