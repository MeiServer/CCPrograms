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

function getOccludedList(list, manualIn, manualBIn)
	local occList = {}
	for k, v in pairs(list) do
		if not v.isManual then
			if v.isOccluded then
				local num = v.name - 1
				if num > 0 then
					table.insert(occList, num)
				end
			end
		else
			if v.onPower then
				table.insert(occList, num)
			end
		end
	end
	occList = tables.unique(occList)
	table.sort(occList)
	return occList
end

function updateBlockage(blockIn, list)
	for i, v in ipairs(list.rail) do
		v.isOccluded = colors.test(blockIn, v.blockColor)
	end
	for i, v in ipairs(list.station) do
		v.isOccluded = colors.test(blockIn, v.blockColor)
	end
	list.next.isOccluded = rs.testBundledInput(nextBlockDir, nextBlockColor)
end

function updateManualData(manualIn, manualBIn, list)
	for k, v in pairs(list) do
		v.isManual = colors.test(manualIn, v.blockColor)
		v.onPower = colors.test(manualBIn, v.blockColor)
	end
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
	updateBlockage(blockIn, list)
	updateManualData(manualIn, manualBIn, list)
	local mixList = getBlockageMixList(list)
	local occList = getOccludedList(mixList, manualIn, manualBIn)
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