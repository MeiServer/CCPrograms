--##Config##
local final outputDir = "top"
local final maxBlockage = 16

--##Function##
function addBlockageForList(list, outtime, leaveTime)
	assert(table.maxn(list) < maxBlockage, "Index Out Of Bounds (Blockage)")
	
	obj = {
		passageTime = 0,
		maxPassageTime = outtime,
		leaveTime = leaveTime,
		color = bit.blshift(1, table.maxn(list) - 1)
	}
	
	table.insert(list, obj)
end

function entryTrain(list, inputColor)
	for i, v in ipairs(list) do
		if colors.test(inputColor, v.color) then
			v.passageTime = v.maxPassageTime
		end
	end
end

function exitTrain(list)
	for i, v in ipairs(list) do
		if v.passageTime < v.leaveTime then
			v.passageTime = 0
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
	
	return outputColor
end

function onUpdate(list, inputColor)
	entryTrain(list, inputColor)
	exitTrain(list)
	--rs.setBundledOutput(outputDir, sendData(list))
	print(sendData(list))
	for i, v in ipairs(list) do
		v.passageTime = v.passageTime - 1
	end
	sleep(0.1)
end

	
--##Main##

local list = {}
addBlockageForList(list, 100, 10)
addBlockageForList(list,  90, 10)
addBlockageForList(list,  80, 10)
addBlockageForList(list,  70, 10)
addBlockageForList(list,  50, 10)
addBlockageForList(list,  40, 10)
addBlockageForList(list,  30, 10)
addBlockageForList(list,  20, 10)
addBlockageForList(list,  20, 10)
addBlockageForList(list, 100, 10)
addBlockageForList(list, 100, 10)
addBlockageForList(list, 100, 10)
addBlockageForList(list, 100, 10)
addBlockageForList(list, 100, 10)
addBlockageForList(list, 100, 10)

local inputColor = 2000 + 51

while true do
	--inputColor = rs.getBundledInput("back")
	onUpdate(list, inputColor)
	sleep(0)
end