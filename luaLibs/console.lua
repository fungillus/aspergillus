console = {}

function console.moveCursor(x, y)
	print(string.format("\x1b[%d;%dH", y, x))
end

function console.clearScreen()
	print("\x1b[2J")
end

function console.resetScreen()
	print("\x1bc")
end
