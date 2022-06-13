console = {}

function console.moveCursor(x, y)
	local ansiCommand = "\x1b[" .. tostring(y) .. ";" .. tostring(x) .. "H"
	print(ansiCommand)
end

function console.clearScreen()
	print("\x1b[2J")
end

function console.resetScreen()
	print("\x1bc")
end
