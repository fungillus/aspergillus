

function Init()
	local convRawUnicodeValueToUnicodeTests = {
		{"first", convRawUnicodeValueToUnicode, {0x28FF}, "⣿"}
		,{"second", convRawUnicodeValueToUnicode, {0x2807}, "⠇"}
		,{"third", convRawUnicodeValueToUnicode, {0x2847}, "⡇"}
		,{"fourth", convRawUnicodeValueToUnicode, {0x28E1}, "⣡"}
		,{"fifth", convRawUnicodeValueToUnicode, {0x28F0}, "⣰"}
	}

	if not doTests("convRawUnicodeValueToUnicode", convRawUnicodeValueToUnicodeTests) then
		return
	end

	local convBrailleToRawUnicodeValueTests = {
		{"1st", convBrailleToRawUnicodeValue, {0x3333}, 0x28FF}
		,{"2nd", convBrailleToRawUnicodeValue, {0x1110}, 0x2807}
		,{"3rd", convBrailleToRawUnicodeValue, {0x1111}, 0x2847}
		,{"4th", convBrailleToRawUnicodeValue, {0x1023}, 0x28E1}
		,{"5th", convBrailleToRawUnicodeValue, {0x0223}, 0x28F0}
	}

	if not doTests("convBrailleToRawUnicodeValue", convBrailleToRawUnicodeValueTests) then
		return
	end

	local convBrailleToUnicodeTests = {
		{"1st", convBrailleToUnicode, {0x3333}, "⣿"}
		,{"2nd", convBrailleToUnicode, {0x1110}, "⠇"}
		,{"3rd", convBrailleToUnicode, {0x1111}, "⡇"}
		,{"4th", convBrailleToUnicode, {0x1023}, "⣡"}
		,{"5th", convBrailleToUnicode, {0x0223}, "⣰"}
	}

	if not doTests("convBrailleToUnicode", convBrailleToUnicodeTests) then
		return
	end

	function bitmapDrawBorder(width, height, borderThickness)
		local bmp = Bitmap:new(width, height)

		bmp:drawBorder(borderThickness)

		return bmp:getBuffer()
	end

	-- Bitmap:drawBorder
	local BitmapDrawBorderTests = {
		{"four by four", bitmapDrawBorder, {4, 4, 1}, [[
⣏⣹
]]}
		,{"eight by eight", bitmapDrawBorder, {8, 8, 1}, [[
⡏⠉⠉⢹
⣇⣀⣀⣸
]]}
		,{"twenty by twenty", bitmapDrawBorder, {20, 20, 1}, [[
⡏⠉⠉⠉⠉⠉⠉⠉⠉⢹
⡇        ⢸
⡇        ⢸
⡇        ⢸
⣇⣀⣀⣀⣀⣀⣀⣀⣀⣸
]]}

		,{"twenty by twenty 2 pixels thick", bitmapDrawBorder, {20, 20, 2}, [[
⣿⠛⠛⠛⠛⠛⠛⠛⠛⣿
⣿        ⣿
⣿        ⣿
⣿        ⣿
⣿⣤⣤⣤⣤⣤⣤⣤⣤⣿
]]}

		,{"twenty by twenty 3 pixels thick", bitmapDrawBorder, {20, 20, 3}, [[
⣿⡿⠿⠿⠿⠿⠿⠿⢿⣿
⣿⡇      ⢸⣿
⣿⡇      ⢸⣿
⣿⡇      ⢸⣿
⣿⣷⣶⣶⣶⣶⣶⣶⣾⣿
]]}
	}

	if not doTests("Bitmap:drawBorder", BitmapDrawBorderTests) then
		return
	end

	function bitmapGetPixel(x, y, width, height, dataBuffer)
		local bmp = Bitmap:new(width, height)

		bmp.data = dataBuffer

		return bmp:getPixel(x, y)
	end

	-- for the braille renderer, the data buffer encodes pixels inside 2x4 items
	-- we use this function to inject all coordinates in the test width by height dataBuffer
	-- and expect only a single coordinate to have the value 1, the rest must have the value 0
	function injectGetPixelTests(testList, description, width, height, dataBuffer, coordinateOfSetPixel)
		local expectedValue = 0
		for y = 0, height - 1 do
			for x = 0, width - 1 do
				if coordinateOfSetPixel.x == x and coordinateOfSetPixel.y == y then
					expectedValue = 1
				else
					expectedValue = 0
				end
				table.insert(testList
					, {
						string.format("%s (%d,%d)", description, x, y)
						, bitmapGetPixel
						, {x, y, width, height, dataBuffer}
						, expectedValue
					})
			end
		end
	end

	local BitmapGetPixelTests = {}

	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x1000", 2, 4, {0x1000}, {x=0, y=0})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x2000", 2, 4, {0x2000}, {x=1, y=0})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x0100", 2, 4, {0x0100}, {x=0, y=1})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x0200", 2, 4, {0x0200}, {x=1, y=1})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x0010", 2, 4, {0x0010}, {x=0, y=2})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x0020", 2, 4, {0x0020}, {x=1, y=2})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x0001", 2, 4, {0x0001}, {x=0, y=3})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 2x4 0x0002", 2, 4, {0x0002}, {x=1, y=3})

	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x1000", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x1000}, {x=2, y=4})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x2000", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x2000}, {x=3, y=4})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x0100", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x0100}, {x=2, y=5})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x0200", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x0200}, {x=3, y=5})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x0010", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x0010}, {x=2, y=6})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x0020", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x0020}, {x=3, y=6})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x0001", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x0001}, {x=2, y=7})
	injectGetPixelTests(BitmapGetPixelTests, "braille pixel 4x8 0x0002", 4, 8,
		{0x0000, 0x0000, 0x0000, 0x0002}, {x=3, y=7})

	table.insert(BitmapGetPixelTests, {"on nil dataBuffer", bitmapGetPixel, {0, 0, 2, 4, {}}, 0})
	table.insert(BitmapGetPixelTests, {"spot check 1", bitmapGetPixel, {0, 0, 2, 4, {0x2013}}, 0})
	table.insert(BitmapGetPixelTests, {"spot check 2", bitmapGetPixel, {1, 0, 2, 4, {0x2013}}, 1})
	table.insert(BitmapGetPixelTests, {"spot check 3", bitmapGetPixel, {0, 1, 2, 4, {0x2013}}, 0})
	table.insert(BitmapGetPixelTests, {"spot check 4", bitmapGetPixel, {0, 2, 2, 4, {0x2013}}, 1})
	table.insert(BitmapGetPixelTests, {"spot check 5", bitmapGetPixel, {0, 3, 2, 4, {0x2013}}, 1})
	table.insert(BitmapGetPixelTests, {"spot check 6", bitmapGetPixel, {1, 3, 2, 4, {0x2013}}, 1})

	table.insert(BitmapGetPixelTests, {"spot check 7", bitmapGetPixel, {3, 5, 4, 8, {0x2013, 0x0000, 0x3100, 0x0031}}, 0})
	table.insert(BitmapGetPixelTests, {"spot check 8", bitmapGetPixel, {3, 6, 4, 8, {0x2013, 0x0000, 0x3100, 0x0031}}, 1})
	table.insert(BitmapGetPixelTests, {"spot check 9", bitmapGetPixel, {2, 6, 4, 8, {0x2013, 0x0000, 0x3100, 0x0031}}, 1})
	table.insert(BitmapGetPixelTests, {"spot check 10", bitmapGetPixel, {1, 6, 4, 8, {0x2013, 0x0000, 0x3100, 0x0031}}, 0})

	if not doTests("Bitmap:getPixel", BitmapGetPixelTests) then
		return
	end
end

function Poll()
	stopGame()
end
