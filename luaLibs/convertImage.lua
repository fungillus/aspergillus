require("tester")

require("debug")

require("basic2")

function packPixels(value1, value2)
	if value1 == " " then
		if value2 == " " then
			return 0
		else
			return 2
		end
	else
		if value2 == " " then
			return 1
		else
			return 3
		end
	end
end

function convertRawTextToBraille(rawText)
	local last = nil
	local buffer={{}}
	local bufferRowIndex=1
	local bufferColIndex=1
	for c in rawText:gmatch(".") do
		if c == "\n" then
			if last ~= nil then
				buffer[bufferRowIndex][bufferColIndex] = packPixels(last, " ")
				last = nil
			end
			bufferRowIndex = bufferRowIndex + 1
			bufferColIndex = 1
			buffer[bufferRowIndex] = {}
		else
			if last == nil then
				last = c
			else
				--print(packPixels(last, c))
				buffer[bufferRowIndex][bufferColIndex] = packPixels(last, c)
				last = nil
				bufferColIndex = bufferColIndex + 1
			end
		end
	end
	-- we remove the last entry as it is empty
	buffer[#buffer] = nil

	local height = #buffer
	--print("height :", height)
	local maxWidth = 0
	for i, v in pairs(buffer) do
		maxWidth = math.max(maxWidth, #v)
	end
	local width = maxWidth * 2
	--print("width :", width)

	local dataResult = {}
	for i = 1, #buffer, 4 do
		for t = 1, maxWidth do
			--[[
			local first = buffer[i] and buffer[i][t] or 0
			local second = buffer[i + 1]
			local third = buffer[i + 2]
			local fourth = buffer[i + 3]
			--]]
			local pixelResult = string.format("0x%d%d%d%d"
				, buffer[i] and buffer[i][t] or 0
				, buffer[i + 1] and buffer[i + 1][t] or 0
				, buffer[i + 2] and buffer[i + 2][t] or 0
				, buffer[i + 3] and buffer[i + 3][t] or 0)
			--print("inserting : ", pixelResult)
			--table.insert(dataResult, pixelResult)
			table.insert(dataResult, tonumber(pixelResult))
		end
	end

	return {width=width, height=height, data=dataResult}
end

function convertBrailleToImage(braille)
	local result = Bitmap:new(braille.width, braille.height)
	result.data = braille.data
	return result
end

function convertRawTextToImage(rawText)
	return convertBrailleToImage(convertRawTextToBraille(rawText))
end

function testConvertImage()
	testCases = {
		{"letter A", convertRawTextToBraille, {[[
  **
 *  *
******
*    *
*    *
 
 
 
]]}, {width=6, height=8, data={0x0231, 0x3030, 0x0132, 0x1000, 0, 0x2000}}}

		,{"letter B", convertRawTextToBraille, {[[
**** 
*   *
**** 
*   *
**** 
     
     
     
]]}, {width=6, height=8, data={0x3131, 0x3030, 0x0101, 0x3000, 0x3000, 0}}}

		,{"letter C", convertRawTextToBraille, {[[
 *** 
*   *
*    
*   *
 *** 
     
     
     
]]}, {width=6, height=8, data={0x2111, 0x3000, 0x0101, 0x2000, 0x3000, 0}}}
}

	doTests("Letters Conversion", testCases)
end

-- check if this script is being run directly with 'lua'
if debug.getinfo(3) == nil then
	--testConvertImage()

	inputFile=arg[1] or "sampleImage.txt"

	if inputFile == "-" then
		f = io.stdin
	else
		f = io.open(inputFile)
	end

	if not f then
		print("Error opening file :", inputFile)
	else
		local buf = f:read("a")
		local resultBrailleImage = convertRawTextToBraille(buf)
		local isFirst = true
		io.write("{", "width=", resultBrailleImage.width, ", height=", resultBrailleImage.height, ", data={")
		for k, v in pairs(resultBrailleImage.data) do
			if isFirst then
				isFirst = false
			else
				io.write(",")
			end
			io.write(v)
		end
		print("}}")
		f:close()
	end
end
