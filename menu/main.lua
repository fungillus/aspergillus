require("basic2")
require("fonts")
require("console")

require("menu")

menuContext = nil

interactive = false

function Init()
	--print "\x1b[25l"
	console.clearScreen()
	local screen = Bitmap:new(128, 120)

	local fonts = Fonts:new()

	-- sound menu
	-- input binding menu
	-- video menu
	--
	-- menu item types : button, configToggle, configValueSlider, configValueSelector
	local menuData = {
		{name = "Main Menu", type = "button", onTrigger = nil, selected = true}
		,{name = "Settings", type = "button", onTrigger = nil}
		,{name = "Quit", type = "button", onTrigger = quit}
	}

	menuContext = Menu:new({screen = screen, fonts = fonts}, {x = 25, y = 20}, menuData)
	menuContext:alignLeft()

	screen:drawBorder(1)

	menuContext:draw()
end

function quit()
	print "\x1b[25h"
	stopGame()
end

if not interactive then
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
end

function handleInputs()
	local currentButtons = getButtonState()

	if currentButtons & buttons.kButtonLeft == buttons.kButtonLeft then
		return
	elseif currentButtons & buttons.kButtonRight == buttons.kButtonRight then
		return
	elseif currentButtons & buttons.kButtonUp == buttons.kButtonUp then
		menuContext:selectPrevious()
	elseif currentButtons & buttons.kButtonDown == buttons.kButtonDown then
		menuContext:selectNext()
	elseif currentButtons & buttons.kButtonA == buttons.kButtonA then
		menuContext:trigger()
	end
end

function Poll()
	handleInputs()
end
