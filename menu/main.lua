
require("basic2")
require("fonts")
require("console")

require("convertImage")

function createButton(fonts, config, text)
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

function giveMiddlePoint(screen, image)
	return (screen.width / 2) - (image.width / 2)
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

function drawMenu(ctx, coordinates, menuData)
	local currentEntry = nil
	local entryImg = nil
	local baseBorderSize = 1
	local borderSize = nil
	local baseCoordinates = {x = coordinates.x, y = coordinates.y}
	local maxXCoordinate = 0
	local calculatedXCoordinate = 0

	local isFirst = true
	local alignment = "left"
	for entryIndex in pairs(menuData) do
		currentEntry = menuData[entryIndex]
		if currentEntry.selected == true then
			borderSize = baseBorderSize + 1
		else
			borderSize = baseBorderSize
		end
		if currentEntry.type == "button" then
			entryImg = createButton(ctx.fonts, {drawBorder = true, borderSize = borderSize}, currentEntry.name)

			if isFirst then
				baseCoordinates.x = giveMiddlePoint(ctx.screen, entryImg)
				maxXCoordinate = baseCoordinates.x + entryImg.width
			end

			calculatedXCoordinate = alignmentCalculation(ctx.screen, entryImg, baseCoordinates.x, maxXCoordinate, alignment)

			ctx.screen:blit(entryImg, calculatedXCoordinate, baseCoordinates.y)
			baseCoordinates.y = baseCoordinates.y + entryImg.height + 2

			if isFirst then
				isFirst = false
			end
		end
	end
end

function clearMenu(ctx, coordinates, menuData)
	local currentEntry = nil
	local entryImg = nil
	local baseBorderSize = 1
	local borderSize = nil
	local baseCoordinates = {x = coordinates.x, y = coordinates.y}
	local maxXCoordinate = 0
	local calculatedXCoordinate = 0

	local isFirst = true
	local alignment = "left"
	for entryIndex in pairs(menuData) do
		currentEntry = menuData[entryIndex]
		if currentEntry.selected == true then
			borderSize = baseBorderSize + 1
		else
			borderSize = baseBorderSize
		end
		if currentEntry.type == "button" then
			entryImg = createButton(ctx.fonts, {drawBorder = true, borderSize = borderSize}, currentEntry.name)

			if isFirst then
				baseCoordinates.x = giveMiddlePoint(ctx.screen, entryImg)
				maxXCoordinate = baseCoordinates.x + entryImg.width
			end

			calculatedXCoordinate = alignmentCalculation(ctx.screen, entryImg, baseCoordinates.x, maxXCoordinate, alignment)

			ctx.screen:blitReverse(entryImg, calculatedXCoordinate, baseCoordinates.y)
			baseCoordinates.y = baseCoordinates.y + entryImg.height + 2

			if isFirst then
				isFirst = false
			end
		end
	end
end

function selectNextMenuEntry(menuData)
	local mustSelectNext = false
	for entryIndex in pairs(menuData) do
		if mustSelectNext == true then
			menuData[entryIndex].selected = true
			break
		end
		if menuData[entryIndex].selected == true then
			if entryIndex == #menuData then -- can't go beyond the last entry element
				break
			end
			menuData[entryIndex].selected = nil
			mustSelectNext = true
		end
	end

	return menuData
end

function selectPreviousMenuEntry(menuData)
	local mustSelectNext = false
	for entryIndex = #menuData, 0, -1 do
		if mustSelectNext == true then
			menuData[entryIndex].selected = true
			break
		end
		if menuData[entryIndex].selected == true then
			if entryIndex == 0 then -- can't go before the first entry element
				break
			end
			menuData[entryIndex].selected = nil
			mustSelectNext = true
		end
	end

	return menuData
end

function triggerMenuEntry(menuData)
	for entryIndex, entry in pairs(menuData) do
		if entry.selected == true then
			if entry.onTrigger ~= nil then
				entry.onTrigger()
			end
		end
	end
end

currentTick = 0
menuContext = {}

function Init()
	--print "\x1b[25l"
	console.clearScreen()
	local screen = Bitmap:new(128, 120)

	local fonts = Fonts:new()

	local ctx = {screen = screen, fonts = fonts}


	local imgUpArrow = convertRawTextToImage([[
   *
  ***
 *****
*******
  ***
  ***
]])

	local imgDownArrow = convertRawTextToImage([[
  ***
  ***
*******
 *****
  ***
   *
]])

	local imgRightArrow = convertRawTextToImage([[
  *
  **
*****
******
*****
  **
  *
]])

	local imgLeftArrow = convertRawTextToImage([[
   *
  **
 *****
******
 *****
  **
   *
]])

	-- sound menu
	-- input binding menu
	-- video menu
	--
	-- menu item types : button, configToggle, configValueSlider, configValueSelector
	menuContext.menuData = {
		{name = "Main Menu", type = "button", onTrigger = nil, selected = true}
		,{name = "Settings", type = "button", onTrigger = nil}
		,{name = "Quit", type = "button", onTrigger = quit}
	}

	menuContext.ctx = ctx
	menuContext.baseMenuCoordinate = {x = 25, y = 20}

	drawMenu(ctx, menuContext.baseMenuCoordinate, menuContext.menuData)

	-- show the arrow images
	screen:blit(imgUpArrow, 7, 2)
	screen:blit(imgLeftArrow, 2, 7)
	screen:blit(imgRightArrow, 13, 7)
	screen:blit(imgDownArrow, 7, 13)

	screen:drawBorder(1)
	screen:draw()
end

function quit()
	print "\x1b[25h"
	stopGame()
end

function setMockButtonsState(tick)
	if tick == 90 then
		quit()
	else
		if tick == 10 then
			return buttons.kButtonDown
		end

		if tick == 20 then
			return buttons.kButtonDown
		end

		if tick == 30 then
			return buttons.kButtonUp
		end

		if tick == 40 then
			return buttons.kButtonUp
		end

		if tick == 50 then
			return buttons.kButtonDown
		end

		if tick == 52 then
			return buttons.kButtonDown
		end

		if tick == 60 then
			return buttons.kButtonA
		end
	end

	return 0
end

function handleInputs()
	local currentButtons = getButtonState()

	if currentButtons & buttons.kButtonLeft == buttons.kButtonLeft then
		return
	elseif currentButtons & buttons.kButtonRight == buttons.kButtonRight then
		return
	elseif currentButtons & buttons.kButtonUp == buttons.kButtonUp then
		clearMenu(menuContext.ctx, menuContext.baseMenuCoordinate, menuContext.menuData)
		menuContext.menuData = selectPreviousMenuEntry(menuContext.menuData)
		drawMenu(menuContext.ctx, menuContext.baseMenuCoordinate, menuContext.menuData)
		menuContext.ctx.screen:draw()
	elseif currentButtons & buttons.kButtonDown == buttons.kButtonDown then
		clearMenu(menuContext.ctx, menuContext.baseMenuCoordinate, menuContext.menuData)
		menuContext.menuData = selectNextMenuEntry(menuContext.menuData)
		drawMenu(menuContext.ctx, menuContext.baseMenuCoordinate, menuContext.menuData)
		menuContext.ctx.screen:draw()
	elseif currentButtons & buttons.kButtonA == buttons.kButtonA then
		triggerMenuEntry(menuContext.menuData)
	end


end

function Poll()
	handleInputs()
end
