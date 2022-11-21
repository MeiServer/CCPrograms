--##Config##
local final tick = 20
local final isSendRetry = false
local final maxElement = 16
local final modemSide = "top"
local final inputSide = "front"
local final Category = {
	rail = "rail",
	station = "station",
	stationNP = "stationNotPass"
	next = "next"
}

--##Block##
local Block = {}

Block.new = function(category, name, color)
	local obj = {}
	obj.category = category
	obj.isOccluded = false
	obj.name = name
	obj.isManual = false
	obj.onPower = true
	obj.color = color
	obj.button = nil
	return obj
end

Block.pp = function(self)
	print(string.format("Category: %s", self.category))
	print(string.format("Color: %s", self.color))
end

--##RailBlock##
local RailBlock = {}

RailBlock.new = function(name, color, outtime, leavetime)
	local obj = Block.new(Category.rail, name, color)
	obj.passageTime = 0
	obj.maxPassageTime = (outtime * tick)
	obj.leaveTime = leavetime * tick
	return obj
end

RailBlock.pp = function(self)
	print(string.format("PassageTime: %d(%d)", self.maxPassageTime, self.maxPassageTime / tick))
	print(string.format("LeaveTime: %d(%d)", self.leaveTime, self.leaveTime / tick))
	Block.pp(self)
end

--##StationBlock##
local StationBlock = {}

StationBlock.new = function(name, color, isMain, y)
	if not isMain then
		name = name.."-"..y
	end
	local obj = Block.new(Category.station, name, color)
	obj.drawY = y
	return obj
end

StationBlock.pp = function(self)
	print(string.format("DrawY Pos: %d", self.drawY))
	Block.pp(self)
end

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

function addBlockageForList(list, category, ...)
	local blockList
	local obj
	
	if category == Category.rail then
		blockList = list.rail
		list.elements = list.elements + 1
		obj = RailBlock.new(list.elements, bit.blshift(1, table.maxn(blockList)), ...)
	elseif category  == Category.station then
		blockList = list.station
		list.elements = list.elements + 1
		obj = StationBlock.new(list.elements, bit.blshift(1, table.maxn(blockList)), true, ...)
	elseif category == Category.stationNP then
		blockList = list.station
		obj = StationBlock.new(list.elements, bit.blshift(1, table.maxn(blockList)), false, ...)
	elseif category  == Category.next then
		blockList = list.next
		obj = Block.new("next", bit.blshift(1, table.maxn(blockList)))
		assert(table.maxn(blockList) < 1, string.format("Index Out Of Bounds (%s)", category))
	end
	assert(table.maxn(blockList) < maxElement, string.format("Index Out Of Bounds (%s)", category))
	
	table.insert(blockList, obj)
end

--##Data##
list = {}
test = makeList(2, 7)
addBlockageForList(test,    Category.rail, 100, 	10)
addBlockageForList(test,    Category.rail,  90, 	10)
addBlockageForList(test,    Category.rail,  80, 	10)
addBlockageForList(test,    Category.rail,  70, 	10)
addBlockageForList(test, Category.station,   10)
addBlockageForList(test, Category.stationNP,   8)
addBlockageForList(test,    Category.rail,  50, 	10)
addBlockageForList(test,    Category.rail,  40, 	10)
addBlockageForList(test,    Category.rail,  30, 	10)
addBlockageForList(test,    Category.rail,  20, 	10)
addBlockageForList(test,    Category.next)
list.test = test

--##Main##
rednet.open(modemSide)
local hour, min = math.modf( os.time() )
local oldmin = math.floor( min * 60 )

while rs.getInput("back") do
	if not rednet.isOpen(modemSide) then
		break
	end
	
	local event, id, str, distance = os.pullEvent("rednet_message")
	
	if id and str and distance then
		rednet.send(id, textutils.serialize(list[str]), true)
	end
	if isSendRetry then
		hour, min = math.modf( os.time() )
		min = math.floor( min * 60 )
	
		if min > oldmin + 1 then
			oldmin = min
			rednet.send(65535, "retry")
			print("send retrymessage: "..hour.." : "..min)
		end
	end
end

rednet.close(modemSide)