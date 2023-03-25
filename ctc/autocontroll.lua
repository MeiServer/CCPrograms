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
function makeList()
	local list = {
		elements = 0,
		rail = {}
		station = {}
		nextBlock = {}
	}
	return list
end

--category = 'rail', 'station', 'next'
function addBlockageForList(list, category)
	--assert(table.maxn(list) < maxBlockage, "Index Out Of Bounds (Blockage)")
	if category ~= "next" then
		local blockList = category == "rail" and list.rail or list.station
		list.elemnts = list.elements + 1
	
		local obj = {
			num = list.elements,
			category = category,
			isOccluded = false,
			color = bit.blshift(1, table.maxn(blockList))
		}
		table.insert(blockList, obj)
	else
		list.nextBlock = {
			category = category,
			isOccluded = false
		}
	end
end

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

function sendData(mixList occList)
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
	rs.setBundledOutput(railColor, railoutDir)
	rs.setBundledOutput(stationColor, stationoutDir)
end

function onUpdate(railIn, stationIn, list)
	updateBlockage(rainIn, stationIn, list)
	local mixList = getBlockageMixList(list)
	local occList = getOccludedList(list)
	sendData(mixList, occList)
end

--##Main##
local list = makeList()
addBlockageForList(list, "rail")
addBlockageForList(list, "rail")
addBlockageForList(list, "rail")
addBlockageForList(list, "rail")
addBlockageForList(list, "station")
addBlockageForList(list, "rail")
addBlockageForList(list, "rail")
addBlockageForList(list, "rail")
addBlockageForList(list, "rail")
addBlockageForList(list, "next")

while rs.testBundledInput(mamualDir, manualColor) do
	local railIn = rs.getBundledInput(raininDir)
	local stationIn = rs.getBundledInput(stationinDir)
	onUpdate(rainIn, stationIn, list)
end