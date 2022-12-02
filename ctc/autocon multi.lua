--name: autocon
--author: niko__25
--version: 0.1.1

--##API##
os.loadAPI("tables")

--##Config##
local final blockOutDir = "front"
local final blockInDir = "back"
local final nextBlockDir = "top"
local final autoDir = "top"
local final manualDir = "back"
local final blockMInDir = "right"
local final rebootDir = "top"
local final nextBlockColor = colors.white
local final manualColor = colors.orange
local final rebootColor = colors.black

--##Function##
function getBlockageMixList(list)
	local obj = {}
	for i, v in ipairs(list.rail) do
		obj[v.name] = v
	end
	for i, v in ipairs(list.station) do
		if v.category ~= "stationNP" then
			obj[v.name] = v
		end
	end
	obj[list.elements + 1] = list.next[1]
	return obj
end

function getOccludedList(list)
	local occList = {}
	for k, v in pairs(list) do
		if v.isOccluded then
			local num = v.name - 1
			if num > 0 then
				table.insert(occList, num)
			end
		end
	end
	table.sort(occList)
	return occList
end

function updateBlockage(blockIn, manualIn, manualBIn, list)
	local colorIn
	for i, v in ipairs(list.rail) do
		if colors.test(manualIn, v.blockColor) then
			colorIn = manualBIn
		else
			colorIn = blockIn
		v.isOccluded = colors.test(colorIn, v.blockColor)
	end
	for i, v in ipairs(list.station) do
		if colors.test(manualIn, v.blockColor) then
			colorIn = manualBIn
		else
			colorIn = blockIn
		v.isOccluded = colors.test(colorIn, v.blockColor)
	end
	list.next.isOccluded = rs.testBundledInput(nextBlockDir, nextBlockColor)
end

function sendData(mixList, occList)
	local blockColor = 0
	for i, v in ipairs(occList) do
		if mixList[v].category ~= "next" then
			local data = mixList[v]
			blockColor = blockColor + data.blockColor
		end
	end
	rs.setBundledOutput(blockOutDir, blockColor)
end

function onUpdate(blockIn, manualIn, manualBIn, list)
	updateBlockage(blockIn, manualIn, manualBIn, list)
	local mixList = getBlockageMixList(list)
	local occList = getOccludedList(mixList)
	sendData(mixList, occList)
end

--##Main##
local list = tables.argsIntoTable(...)

while rs.testBundledInput(rebootDir, rebootColor) do
	if rs.testBundledInput(autoDir, manualColor) then
		local blockIn = rs.getBundledInput(blockInDir)
		local manualIn = rs.getBundledInput(manualDir)
		local manualBIn = rs.getBundledInput(manualBInDir)
		onUpdate(blockIn, manualIn, manualBin, list)
	end
end