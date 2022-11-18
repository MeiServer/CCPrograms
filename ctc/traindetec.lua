--##Config##
local final outputDir = "top"
local final inputEntryDir = "right"
local final inputExitDir = "left"

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
			outputColor = outputColor + v.color
		end
	end
	
	rs.setBundledOutput(outputDir, outputColor)
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

local list = {...}
list = list.rail

while rs.getInput("front") do
	local entryColor = rs.getBundledInput(inputEntryDir)
	local exitColor = rs.getBundledInput(inputExitDir)
	onUpdate(list, entryColor, exitColor)
	sleep(0)
end