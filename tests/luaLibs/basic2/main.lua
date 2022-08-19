

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
		-- NOTE that empty spaces are unicode empty braille, not normal spaces
		-- we should probably fix that
		,{"twenty by twenty", bitmapDrawBorder, {20, 20, 1}, [[
⡏⠉⠉⠉⠉⠉⠉⠉⠉⢹
⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸
⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸
⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸
⣇⣀⣀⣀⣀⣀⣀⣀⣀⣸
]]}
	}

	if not doTests("BitmapDrawBorder", BitmapDrawBorderTests) then
		return
	end
end

function Poll()
	stopGame()
end
