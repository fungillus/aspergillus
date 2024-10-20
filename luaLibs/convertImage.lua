require("debug")

require("basic2")

function convertRawTextToImage(rawText)
	local height = 0
	local width = 0
	local i = 0
	local x = 0
	local y = 0

	-- figure out how big the output bitmap will have to be
	for c in rawText:gmatch(".") do
		if c == "\n" then
			if i > width then
				width = i
			end
			height = height + 1
			i = 0
		else
			i = i + 1
		end
	end

	local result = Bitmap:new(width, height)

	for c in rawText:gmatch(".") do
		if c == "\n" then
			y = y + 1
			x = 0
		elseif c ~= " " then
			result:putPixel(x, y, 1)
			x = x + 1
		else
			result:putPixel(x, y, 0)
			x = x + 1
		end
	end

	return result
end


-- check if this script is being run directly with 'lua'
if debug.getinfo(3) == nil then

	require("braille")

	inputFile=arg[1] or "sampleImage.txt"

	if inputFile == "-" then
		f = io.stdin
	else
		f = io.open(inputFile)
	end

	if not f then
		print("Error opening file :", inputFile)
	else
		local isFirst = true
		local result = convertRawTextToImage(f:read("a"))
		local size = result:getSize()
		local realSize = result:getRealSize()
		local i = 0

		local buffer = result:getBuffer()
		io.write("{width=", size.width, ", height=", size.height, ", data={")
		for i = 1, realSize.width * realSize.height do
			if isFirst then
				isFirst = false
			else
				io.write(",")
			end
			if not buffer[i] then
				io.write("0")
			else
				io.write("\"")
				io.write(buffer[i])
				io.write("\"")
			end
		end
		print("}}")
		f:close()
	end
end
