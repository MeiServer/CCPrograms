--name: traindetec
--author: niko__25
--version: 0.1.1
--reversal rebootstate
--rename Config

--##API##
os.loadAPI("tables")

--##Config##
local final outputSide = "back"
local final inputEntrySide = "right"
local final inputExitSide = "left"
local final rebootSide = "top"

--##Function##
function entryTrain(list, entryColor)
	for i, v in ipairs(list) do
		if colors.test(entryColor, v.color) then
			v.passageTime = v.maxPassageTime
		end
	end
end

function exitTrain(list, exitColor)
	for i, v in ipairs(list) do
		if v.passageTime > 0 then
			if colors.test(exitColor, v.color) and v.passageTime < v.leaveTime then
				v.passageTime = 0
			end
		end
	end
end

function sendData(list)
	local outputColor = 0
	for i, v in ipairs(list) do
		if v.passageTime > 0 then
			outputColor = outputColor + v.blockColor
		end
	end
	
	rs.setBundledOutput(outputSide, outputColor)
end

function onUpdate(list, entryColor, exitColor)
	for i, v in ipairs(list) do
		if v.passageTime > 0 then
			v.passageTime = v.passageTime - 1
			print(string.format("Color: %d, Time: %d", v.color, v.passageTime))
		end
	end
	entryTrain(list, entryColor)
	exitTrain(list, exitColor)
	sendData(list)
end

	
--##Main##

local list = tables.argsIntoTable(...)
list = list.rail

while not rs.getInput(rebootSide) do
	local entryColor = rs.getBundledInput(inputEntrySide)
	local exitColor = rs.getBundledInput(inputExitSide)
	onUpdate(list, entryColor, exitColor)
	sleep(0)
end