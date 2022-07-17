
function doTest(testDescription, functionToTest, functionArguments, expectedResult)

	io.write("Test " .. testDescription .. " : ")

	local result = functionToTest(table.unpack(functionArguments))

	if (result == expectedResult) then
		print("\x1b[38;5;10mpassed\x1b[0m")
		return true
	else 
		print("\x1b[38;5;1mfailed\x1b[0m\n"
			,"We got : " .. tostring(result) .. "\n"
			,"rather than : " .. tostring(expectedResult))
		return false
	end
end

-- testTable is a table of tables where each entry contains :
-- {testDescription, functionToTest, functionArguments, expectedResult}
function doTests(testBlockDescription, testTable)
	print("Test Section : " .. testBlockDescription)

	for i = 1, #testTable do
		if not doTest(table.unpack(testTable[i])) then
			return false
		end
	end

	return true
end

function aba(a, b)
	return a + b
end

function testAba()
	local tests = {
		{"one", aba, {1, 2}, 3}
		,{"two", aba, {3, 4}, 7}
		,{"three", aba, {5, 7}, 12}
	}

	doTests("testing aba", tests)
end

function assert2(conditionnal, message)
	if conditionnal then
		return true
	else
		print("\n\t" .. message)
		return false
	end
end

--testAba()
