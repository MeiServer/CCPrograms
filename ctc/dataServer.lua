--##Config##
local final tick = 20
local final maxElement = 16
local final modemSide = "top"
local final inputSide = "front"
local final Category = {
	rail = "rail",
	station = "station",
	next = "next"
}

--##Function##
function makeList(x, y)
	local obj = {}
	obj.drawX = x
	obj.drawY = y
	obj.elements = 0
	obj.rail = {}
	obj.station = {}
	obj.next = {}

	return obj
end

function addBlockageForList(list, category, outtime, leavetime)
	local blockList
	
	if category == Category.rail then
		blockList = list.rail
		list.elements = list.elements + 1
	elseif category  == Category.station then
		blockList = list.station
		list.elements = list.elements + 1
	elseif category  == Category.next then
		blockList = list.next
		assert(table.maxn(blockList) < 1, string.format("Index Out Of Bounds (%s)", category))
	end
	
	assert(table.maxn(blockList) < maxElement, string.format("Index Out Of Bounds (%s)", category))
	
	local obj = {}
	obj.category = category
	obj.isOccluded = false
	
	if not category == Category.next then
		obj.name = list.elements
		obj.isManual = false
		obj.onPower = true
		obj.color = bit.blshift(1, table.maxn(blockList))
		obj.button = nil
		
		if category == Category.rail then
			obj.passageTime = 0
			obj.maxPassageTime = outtime * tick
			obj.leaveTime = leavetime * tick
		end
	end
end

--##Data##
list = {}
list[1] = makeList(2, 7)
addBlockageForList(list[1],    Category.rail, 100, 	10)
addBlockageForList(list[1],    Category.rail,  90, 	10)
addBlockageForList(list[1],    Category.rail,  80, 	10)
addBlockageForList(list[1],    Category.rail,  70, 	10)
addBlockageForList(list[1], Category.station, nil, nil)
addBlockageForList(list[1],    Category.rail,  50, 	10)
addBlockageForList(list[1],    Category.rail,  40, 	10)
addBlockageForList(list[1],    Category.rail,  30, 	10)
addBlockageForList(list[1],    Category.rail,  20, 	10)
addBlockageForList(list[1],    Category.next, nil, nil)

--##Main##
rednet.open(modemSide)

while rs.getInput("back") do
	if not rednet.isOpen(modemSide) then
		break
	end
	
	local id, str, distance = os.pullEvent("rednet_message")
	
	if id and str and distance then
		rednet.send(id, textutils.serialize(list[str]), true)
	end
end

rednet.close(modemSide)