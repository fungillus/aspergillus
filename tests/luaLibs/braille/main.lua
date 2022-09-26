--[[

this test file is for the library braille.lua

functions to test :

convRawUnicodeValueToUnicode
convBrailleToRawUnicodeValue
convBrailleToUnicode
Bitmap:getPixel
Bitmap:putPixel
Bitmap:marshalRow
Bitmap:drawBorder

Bitmap:clear
Bitmap:getBuffer
Bitmap:draw
Bitmap:blit
Bitmap:blitSection
Bitmap:blitReverse
Bitmap:isRectangleEmpty

--]]

function testConvRawUnicodeValueToUnicode()
	local convRawUnicodeValueToUnicodeTests = {
		{"first", convRawUnicodeValueToUnicode, {0x28FF}, "⣿"}
		,{"second", convRawUnicodeValueToUnicode, {0x2807}, "⠇"}
		,{"third", convRawUnicodeValueToUnicode, {0x2847}, "⡇"}
		,{"fourth", convRawUnicodeValueToUnicode, {0x28E1}, "⣡"}
		,{"fifth", convRawUnicodeValueToUnicode, {0x28F0}, "⣰"}
	}

	if not doTests("convRawUnicodeValueToUnicode", convRawUnicodeValueToUnicodeTests) then
		return false
	else
		return true
	end
end

function testConvBrailleToRawUnicodeValue()
	local convBrailleToRawUnicodeValueTests = {
		{"1st", convBrailleToRawUnicodeValue, {0x3333}, 0x28FF}
		,{"2nd", convBrailleToRawUnicodeValue, {0x1110}, 0x2807}
		,{"3rd", convBrailleToRawUnicodeValue, {0x1111}, 0x2847}
		,{"4th", convBrailleToRawUnicodeValue, {0x1023}, 0x28E1}
		,{"5th", convBrailleToRawUnicodeValue, {0x0223}, 0x28F0}
	}

	if not doTests("convBrailleToRawUnicodeValue", convBrailleToRawUnicodeValueTests) then
		return false
	else
		return true
	end
end

function testConvBrailleToUnicode()
	local convBrailleToUnicodeTests = {
		{"1st", convBrailleToUnicode, {0x3333}, "⣿"}
		,{"2nd", convBrailleToUnicode, {0x1110}, "⠇"}
		,{"3rd", convBrailleToUnicode, {0x1111}, "⡇"}
		,{"4th", convBrailleToUnicode, {0x1023}, "⣡"}
		,{"5th", convBrailleToUnicode, {0x0223}, "⣰"}
	}

	if not doTests("convBrailleToUnicode", convBrailleToUnicodeTests) then
		return false
	else
		return true
	end
end

function testBitmapMarshalRow()
	local mainBitmap = Bitmap:new(10, 16)

	-- first row 
	-- 0 to 3
	-- all 3000
	for x = 0, 10 - 1 do
		mainBitmap:putPixel(x, 0, 1)
	end

	-- second row
	-- 4 to 7
	-- all 0300
	for x = 0, 10 - 1 do
		mainBitmap:putPixel(x, 5, 1)
	end

	-- third row
	-- 8 to 11
	-- all 0030
	for x = 0, 10 - 1 do
		mainBitmap:putPixel(x, 10, 1)
	end

	-- fourth row
	-- 12 to 15
	-- all 0003
	for x = 0, 10 - 1 do
		mainBitmap:putPixel(x, 15, 1)
	end



	local mainBitmap2 = Bitmap:new(10, 16)

	-- first row 
	-- 0 to 3
	-- all 1000
	for x = 0, 10 - 1, 2 do
		mainBitmap2:putPixel(x, 0, 1)
		mainBitmap2:putPixel(x + 1, 0, 0)
	end

	-- second row
	-- 4 to 7
	-- all 0200
	for x = 0, 10 - 1, 2 do
		mainBitmap2:putPixel(x, 5, 0)
		mainBitmap2:putPixel(x + 1, 5, 1)
	end

	-- third row
	-- 8 to 11
	-- all 0030
	for x = 0, 10 - 1, 2 do
		mainBitmap2:putPixel(x, 10, 1)
		mainBitmap2:putPixel(x + 1, 10, 1)
	end

	-- fourth row
	-- 12 to 15
	-- all 0000
	for x = 0, 10 - 1, 2 do
		mainBitmap2:putPixel(x, 15, 0)
		mainBitmap2:putPixel(x + 1, 15, 0)
	end


	local marshalTest = function (bitmap, row)
		return bitmap.core:marshalRow(row)
	end

	local tests = {
		{"first row", marshalTest, {mainBitmap, 0}, [[
⠉⠉⠉⠉⠉]]}
		,{"second row", marshalTest, {mainBitmap, 1}, [[
⠒⠒⠒⠒⠒]]}
		,{"third row", marshalTest, {mainBitmap, 2}, [[
⠤⠤⠤⠤⠤]]}
		,{"fourth row", marshalTest, {mainBitmap, 3}, [[
⣀⣀⣀⣀⣀]]}

		-- mainBitmap2
		,{"first row v2", marshalTest, {mainBitmap2, 0}, [[
⠁⠁⠁⠁⠁]]}
		,{"second row v2", marshalTest, {mainBitmap2, 1}, [[
⠐⠐⠐⠐⠐]]}
		,{"third row v2", marshalTest, {mainBitmap2, 2}, [[
⠤⠤⠤⠤⠤]]}
		,{"fourth row v2", marshalTest, {mainBitmap2, 3}, [[
     ]]}
	}

	if not doTests("Bitmap:marshalRow", tests) then
		return false
	else
		return true
	end
end

function testBitmapDrawBorder()
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
		return false
	else
		return true
	end
end

function testBitmapGetPixel()
	function bitmapGetPixel(x, y, width, height, dataBuffer)
		local bmp = Bitmap:new(width, height)

		bmp.core.data = dataBuffer

		return bmp:getPixel(x, y)
	end

	-- for the braille renderer, the data buffer encodes pixels inside 2x4 elements
	-- we use this function to inject test entries for all coordinates in the dataBuffer
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
		return false
	else
		return true
	end
end

function testBitmapPutPixel()
	-- at this point, we know that getPixel works according to specs so we can use it.
	local width = 30
	local height = 30
	local bmp = Bitmap:new(width, height)

	function testPutPixel(bmp, toCheckCoord)
		local result = true
		local pixelValue = 0
		local foundCheckCoord = false
		local bmpSize = bmp:getSize()
		bmp:putPixel(toCheckCoord.x, toCheckCoord.y, 1)
		for y = 0, bmpSize.height - 1 do
			for x = 0, bmpSize.width - 1 do
				pixelValue = bmp:getPixel(x, y)

				if toCheckCoord.x == x and toCheckCoord.y == y then
					if pixelValue == 0 then
						result = false
					else
						foundCheckCoord = true
					end
				else
					if pixelValue == 1 then result = false end
				end
			end
		end
		bmp:putPixel(toCheckCoord.x, toCheckCoord.y, 0)

		if foundCheckCoord == false then
			result = false
		end

		return result
	end

	local tests = {
		{"Spot check 1", testPutPixel, {bmp, {x = 20, y = 20}}, true}
		,{"Spot check 2", testPutPixel, {bmp, {x = 29, y = 29}}, true}
		,{"Out of bound check", testPutPixel, {bmp, {x = 60, y = 60}}, false}
		,{"Out of bound check 2", testPutPixel, {bmp, {x = 30, y = 30}}, false}
		,{"X check", testPutPixel, {bmp, {x = 29, y = 0}}, true}
		,{"X check out of bound", testPutPixel, {bmp, {x = 30, y = 0}}, false}
		,{"Y check", testPutPixel, {bmp, {x = 0, y = 29}}, true}
		,{"Y check out of bound", testPutPixel, {bmp, {x = 0, y = 30}}, false}
		,{"Single block check 0,0", testPutPixel, {bmp, {x = 0, y = 0}}, true}
		,{"Single block check 1,0", testPutPixel, {bmp, {x = 1, y = 0}}, true}
		,{"Single block check 0,1", testPutPixel, {bmp, {x = 0, y = 1}}, true}
		,{"Single block check 1,1", testPutPixel, {bmp, {x = 1, y = 1}}, true}
		,{"Single block check 0,2", testPutPixel, {bmp, {x = 0, y = 2}}, true}
		,{"Single block check 1,2", testPutPixel, {bmp, {x = 1, y = 2}}, true}
		,{"Single block check 0,3", testPutPixel, {bmp, {x = 0, y = 3}}, true}
		,{"Single block check 1,3", testPutPixel, {bmp, {x = 1, y = 3}}, true}
	}

	if not doTests("Bitmap:putPixel", tests) then
		return false
	else
		return true
	end
end

function Init()
	if not testConvRawUnicodeValueToUnicode() then return end

	if not testConvBrailleToRawUnicodeValue() then return end

	if not testConvBrailleToUnicode() then return end

	if not testBitmapGetPixel() then return end

	if not testBitmapPutPixel() then return end

	if not testBitmapMarshalRow() then return end

	if not testBitmapDrawBorder() then return end
end

function Poll()
	stopGame()
end
