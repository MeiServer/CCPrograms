--name: autocon
--author: niko__25
--version: 0.1.2
--fix manual block name
--fix vararg error (77:expected 'end')
--reflect manualcontroll in occList
--rename category
--rename Configration

--##API##
os.loadAPI("tables")

--##Config##
local final areaOutSide = "front"
local final areaInSide = "back"
local final nextAreaSide = "top"
local final autoSide = "top"
local final manualSide = "back"
local final manualAreaInSide = "right"
local final rebootSide = "top"
local final nextAreaColor = colors.white
local final manualColor = colors.orange
local final rebootColor = colors.black

--##Function##
function getBlockageMixList(list)
	local obj = {}
	for i, v in ipairs(list.rail) do
		obj[v.name] = v
	end
	for i, v in ipairs(list.station) do
		if v.category ~= "stationsub" then
			obj[v.name] = v
		end
	end
	obj[list.elements + 1] = list.next[1]
	return obj
end

function getOccludedList(list)
	local occList = {}
	for k, v in pairs(list) do
		local preName = v.name - 1
		if preName > 0 then
			if not list[preName].isManual then
				if v.isOccluded then
					table.insert(occList, preName)
				end
			end
		end
		if v.isManual and v.onPower then
			table.insert(occList, num)
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
	list.next.isOccluded = rs.testBundledInput(nextAreaSide, nextAreaColor)
end

function updateManualData(manualIn, blockMIn, list)
	for k, v in pairs(list.rail) do
		v.isManual = colors.test(manualIn, v.blockColor)
		v.onPower = colors.test(blockMIn, v.blockColor)
	end
	for k, v in pairs(list.station) do
		v.isManual = colors.test(manualIn, v.blockColor)
		v.onPower = colors.test(blockMIn, v.blockColor)
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
	rs.setBundledOutput(areaOutSide, blockColor)
end

function onUpdate(blockIn, manualIn, blockMIn, list)
	updateBlockage(blockIn, list)
	updateManualData(manualIn, blockMIn, list)
	local mixList = getBlockageMixList(list)
	local occList = getOccludedList(mixList)
	sendData(mixList, occList)
end

--##Main##
local list = tables.argsIntoTable(...)

while rs.testBundledInput(rebootSide, rebootColor) do
	if rs.testBundledInput(autoSide, manualColor) then
		local blockIn = rs.getBundledInput(areaInSide)
		local manualIn = rs.getBundledInput(manualSide)
		local blockMIn = rs.getBundledInput(manualAreaInSide)
		onUpdate(blockIn, manualIn, blockMIn, list)
	end
end