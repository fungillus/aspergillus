console = {}

function console.moveCursor(x, y)
	io.write(string.format("\x1b[%d;%dH", y, x))
	-- just in case, we also use another ansi escape just to move the X axis
	--print(string.pack("BBc3B", 0x1b, 0x5b, string.format("%0.3d", x), 0x47))
	--io.write(string.format(""))
end

function console.clearScreen()
	print("\x1b[2J")
end

function console.resetScreen()
	print("\x1bc")
end
