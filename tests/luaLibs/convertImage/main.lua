
function extractBuf(input)
	local img = convertRawTextToImage(input)
	local size = img:getSize()
	local realSize = img:getRealSize()
	local buffer = img:getBuffer()

	for i = 1, realSize.width * realSize.height do
		if buffer[i] == nil then
			buffer[i] = 0
		end
	end
	return {width= size.width, height= size.height, data=buffer}
end

function testConvertImage()
	testCases = {
		{"letter A", extractBuf, {[[
  **
 *  *
******
*    *
*    *
 
 
 
]]}, {width=6, height=8, data={"⡴", "⠭", "⢦", "⠁", 0, "⠈"}}}
--]]}, {width=6, height=8, data={0x0231, 0x3030, 0x0132, 0x1000, 0, 0x2000}}}

		,{"letter B", extractBuf, {[[
**** 
*   *
****
*   *
**** 
     
     
     
]]}, {width=5, height=8, data={"⡯", "⠭", "⡂", "⠉", "⠉", 0}}}
--]]}, {width=6, height=8, data={0x3131, 0x3030, 0x0101, 0x3000, 0x3000, 0}}}

		,{"letter C", extractBuf, {[[
 *** 
*   *
*    
*   *
 *** 
     
     
     
]]}, {width=5, height=8, data={"⡎", "⠉", "⡂", "⠈", "⠉", 0}}}
--]]}, {width=6, height=8, data={0x2111, 0x3000, 0x0101, 0x2000, 0x3000, 0}}}
}

	doTests("Letters Conversion", testCases)
end

function Init()
	testConvertImage()
end

function Poll()
	stopGame()
end
