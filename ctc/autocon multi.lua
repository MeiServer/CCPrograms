--name: autocon
--author: niko__25
--version: 0.1

--##API##
os.loadAPI("tables")

--##Config##
local final blockOutDir = "front"
local final blockInDir = "back"
local final nextBlockDir = "top"
local final manualDir = "top"
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

function updateBlockage(blockIn, list)
	for i, v in ipairs(list.rail) do
		v.isOccluded = colors.test(blockIn, v.blockColor)
	end
	for i, v in ipairs(list.station) do
		v.isOccluded = colors.test(blockIn, v.blockColor)
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
	end
	rs.setBundledOutput(blockOutDir, blockColor)
end

function onUpdate(blockIn, list)
	updateBlockage(blockIn, list)
	local mixList = getBlockageMixList(list)
	local occList = getOccludedList(mixList)
	sendData(mixList, occList)
end

--##Main##
local list = tables.argsIntoTable(...)

while rs.testBundledInput(rebootDir, rebootColor) do
	local blockIn = rs.getBundledInput(blockInDir)
	onUpdate(blockIn, list)
end