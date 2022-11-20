--##API##
os.loadAPI("tables")

--##Config##
local final railoutDir = "front"
local final stationoutDir = "back"
local final railinDir = "left"
local final stationinDir = "right"
local final nextBlockDir = "top"
local final manualDir = "top"
local final nextBlockColor = colors.white
local final manualColor = colors.orange

--##Function##
function getBlockageMixList(list)
	local obj = {}
	for i, v in ipairs(list.rail) do
		obj[v.num] = v
	end
	for i, v in ipairs(list.station) do
		obj[v.num] = v
	end
	obj[list.elements + 1] = list.nextBlock
	return obj
end

function getOccludedList(list)
	local occList = {}
	
	for k, v in pairs(list) do
		if v.isOccluded then
			table.insert(occList, v.num - 1)
		end
	end
	table.insert(occList, list.nextBlock)
	table.sort(occList)
	return occList
end

function updateBlockage(railIn, stationIn, list)
	for i, v in ipairs(list.rail) do
		v.isOccluded = colors.test(railIn, v.color)
	end
	
	for i, v in ipairs(list.station) do
		v.isOccluded = colors.test(stationIn, v.color)
	end
	
	list.nextBlock.isOccluded = rs.testBundledInput(nextBlockDir, nextBlockColor)
end

function sendData(mixList, occList)
	local railColor = 0
	local stationColor = 0
	
	for i, v in ipairs(occList) do
		if mixList[v].category ~= "next" then
			local data = mixList[v]
			if data.category == "rail" then
				railColor = railColor + data.color
			else
				stationColor = stationColor + data.color
			end
		end
	end
	rs.setBundledOutput(railoutDir, railColor)
	rs.setBundledOutput(stationoutDir, stationColor)
end

function onUpdate(railIn, stationIn, list)
	updateBlockage(railIn, stationIn, list)
	local mixList = getBlockageMixList(list)
	local occList = getOccludedList(mixList)
	sendData(mixList, occList)
end

--##Main##
local list = tables.argsIntoTable(...)

while rs.testBundledInput(manualDir, manualColor) do
	local railIn = rs.getBundledInput(railinDir)
	local stationIn = rs.getBundledInput(stationinDir)
	onUpdate(railIn, stationIn, list)
end