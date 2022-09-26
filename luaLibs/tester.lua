
function isEq(value1, value2)
	if type(value1) == "table" and type(value2) == "table" then
		if #value1 ~= #value2 then
			return false
		else
			for key, value in pairs(value1) do
				if not isEq(value, value2[key]) then
					return false
				end
			end
			return true
		end
	else
		return value1 == value2
	end
end

--print(isEq({data={1}}, {data={1}}))

function prettyPrintTable(tableData)
	local result = ""
	if type(tableData) == "table" then
		result = "{"
		for key, value in pairs(tableData) do
			if type(value) == "table" then
				result = result .. "," .. prettyPrintTable(value)
			else
				result = result .. "," .. tostring(value)
			end
		end
	end
	return result .. "}"
end

function doTest(testDescription, functionToTest, functionArguments, expectedResult)

	io.write("Test " .. testDescription .. " : ")

	local result = functionToTest(table.unpack(functionArguments))

	if (isEq(result, expectedResult) and isEq(expectedResult, result)) then
		print("\x1b[38;5;10mpassed\x1b[0m")
		return true
	else 
		print("\x1b[38;5;1mfailed\x1b[0m")
		if type(result) == "table" then
			--print("We got :", table.unpack(result) or "nothing")
			print("We got :", prettyPrintTable(result))
		else
			print("We got :", tostring(result))
		end
		if type(expectedResult) == "table" then
			--print("rather than :", table.unpack(expectedResult) or "nothing")
			print("rather than :", prettyPrintTable(expectedResult))
		else
			print("rather than :", tostring(expectedResult))
		end
		return false
	end
end

-- testTable is a table of tables where each entry contains :
-- {testDescription, functionToTest, functionArguments, expectedResult}
function doTests(testBlockDescription, testTable)
	print("Test Section : " .. testBlockDescription)

	for i = 1, #testTable do
		io.stdout:write("	")
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
