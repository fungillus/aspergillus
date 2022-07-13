
require("basic2")
require("fonts")
require("console")

function createButton(ctx, config, text)
	config = config or {}

	if config.drawBorder == nil then
		config.drawBorder = false
	end

	if config.borderSize == nil then
		config.borderSize = 1
	end

	local width = ctx.fonts:getCharacterWidth() * #text
	local height = ctx.fonts:getCharacterHeight()

	local textStartX = 0
	local textStartY = 0

	if config.drawBorder then
		height = height + (config.borderSize * 2) + 2

		width = width + (config.borderSize * 2) + 4

		textStartX = config.borderSize + 2
		textStartY = config.borderSize + 2
	end

	local bitmap = Bitmap:new(width, height)

	ctx.fonts:printText(bitmap, {x=textStartX, y=textStartY}, text)

	if config.drawBorder then
		bitmap:drawBorder(config.borderSize)
	end

	return bitmap
end

function Init()
	--print "\x1b[25l"
	console.clearScreen()
	local bitmap = Bitmap:new(100, 100)

	local fonts = Fonts:new()

	local ctx = {bitmap = bitmap, fonts = fonts}

	local btnMainMenu = createButton(ctx, {drawBorder = true, borderSize = 2}, "Main Menu")
	local btnSettings = createButton(ctx, {drawBorder = true, borderSize = 1}, "Settings")
	local btnQuit = createButton(ctx, {drawBorder = true, borderSize = 1}, "Quit")

	local baseMenuCoordinates = {x = 30, y = 20}

	bitmap:blit(btnMainMenu, baseMenuCoordinates.x, baseMenuCoordinates.y)
	baseMenuCoordinates.y = baseMenuCoordinates.y + btnMainMenu.height + 2

	bitmap:blit(btnSettings, baseMenuCoordinates.x, baseMenuCoordinates.y)
	baseMenuCoordinates.y = baseMenuCoordinates.y + btnSettings.height + 2

	bitmap:blit(btnQuit, baseMenuCoordinates.x, baseMenuCoordinates.y)
	baseMenuCoordinates.y = baseMenuCoordinates.y + btnQuit.height + 2

	bitmap:draw()
end

function Poll()
	print "\x1b[25h"
	stopGame()
end
