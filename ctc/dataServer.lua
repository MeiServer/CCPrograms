
--##API##
os.loadAPI("tables")

--##Config##
local final tick = 20
local final maxElement = 16
local final modemSide = "top"
local final inputSide = "front"
local final StateList = {
	default = {colors.white},
	powerOn = {colors.green, colors.yellow, colors.white},
	powerOff = {colors.red, colors.yellow, colors.white},
	autoOn = {colors.yellow},
	autoOff = {colors.black}
}

--##Function##
function makeListAndInsert()
	local obj = {}
	obj.elements = 0
	obj.rail = {}
	obj.station = {}
	obj.next = {}

	return obj
end

function addBlockageForList(list, category, outtime, leavetime, x, y)
	local blockList
	
	if category == Category.rail then
		blockList = list.rail
		list.elements = list.elements + 1
	elseif category  == Category.station then
		blockList = list.station
		list.elements = list.elements + 1
	elseif category  == Category.next then
		blockList = list.next
	end
	
	assert(table.maxn(blockList) < maxElement, string.format("Index Out Of Bounds (%s)", category))
	
	local obj = {}
	obj.category = category
	obj.isOccluded = false
	
	if not category == Category.next then
		obj.name = list.elements
		obj.passageTime = 0
		obj.maxPassageTime = outtime * tick
		obj.leaveTime = leavetime * tick
		obj.isManual = false
		obj.onPower = true
		obj.color = bit.blshift(1, table.maxn(blockList))
		obj.button = nil
	end
end

--##Data##
list = {}

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