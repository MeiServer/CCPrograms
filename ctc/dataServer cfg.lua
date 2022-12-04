--name: dataServer
--author: niko__25
--version: 0.1.1
--supported configration
--rename category
--change to match config

--##Config##
local final tick = 20
local final isSendRetry = false
local final maxElement = 16
local final modemSide = "top"
local final inputSide = "front"
local final Category = {
	rail = "rail",
	station = "station",
	stationsub = "stationsub",
	point = "point",
	next = "next"
}

--##Configration##
function loadConfig(name)
	local file = assert(fs.open(name, "r"), name.." is not open")
	local text = assert(file.readLine(), string.format("This file ('%s') is empty ", name))
	local data = {}
	local name = ""
	while text do
		local list = strings.split(text, ",")
		if list[1] == "group" then
			name = assert(list[2], "groupName is nil")
			data[name] = {
				x = list[2],
				y = list[3],
				isOut = list[4],
				area = {}
			}
		elseif list[1] == "areastart" then
			text = assert(file.readLine(), string.format("'next' expected (to close 'area' at group %s)", name))
			list = strings.split(text, ",")
			while list[1] ~= "next" do
				local area = {
					category = table.remove(list, 1),
					args = list
				}
				assert(data[name], name.." is not found")
				table.insert(data[name], area)
				text = assert(file.readLine(), string.format("'next' expected (to close 'area' at group %s)", name))
				list = strings.split(text, ",")
			end
			local area = {
					category = table.remove(list, 1),
					args = list
			}
			table.insert(data[name].area, area)
		end
		text = file.readLine()
	end
	file.close()
	return data
end

--##Block##
local Block = {}

Block.new = function(category, name, color, bcolor)
	local obj = {}
	obj.category = category
	obj.isOccluded = false
	obj.name = name
	obj.isManual = false
	obj.onPower = true
	obj.color = color
	obj.blockColor = bcolor
	obj.button = true
	return obj
end

Block.pp = function(self)
	print(string.format("Category: %s", self.category))
	print(string.format("Color: %s", self.color))
end

--##RailBlock##
local RailBlock = {}

RailBlock.new = function(name, color, bcolor, args)
	assert(args[1] < args[2], string.format("%s: Leaving time is greater than passing time", tostring(name)))
	local obj = Block.new(Category.rail, name, color, bcolor)
	obj.passageTime = 0
	obj.maxPassageTime = (args[2] * tick)
	obj.leaveTime = args[1] * tick
	return obj
end

RailBlock.pp = function(self)
	print(string.format("PassageTime: %d(%d)", self.maxPassageTime, self.maxPassageTime / tick))
	print(string.format("LeaveTime: %d(%d)", self.leaveTime, self.leaveTime / tick))
	Block.pp(self)
end

--##StationBlock##
local StationBlock = {}

StationBlock.new = function(name, color, bcolor, isMain, args)
	if not isMain then
		name = name.."-"..args[1]
	end
	local obj = Block.new(Category.station, name, color, bcolor)
	obj.drawY = args[1]
	return obj
end

StationBlock.pp = function(self)
	print(string.format("DrawY Pos: %d", self.drawY))
	print(string.format("StationLine: %s", self.isMain and "Main" or "Sub"))
	Block.pp(self)
end

--##Point##
local Point = {}

Point.new = function(name, color, args)
	name = name.."-point"
	local obj = Block.new(Category.point, name, color)
	obj.onPower = false
	obj.drawX = args[1]
	obj.drawY = args[2]
	return obj
end

Point.pp = function(self)
	print(string.format("Draw Pos: (%d, %d)", self.drawX, self.drawY))
	Block.pp(self)
end

--##Function##
function makeList(x, y, isOut)
	local obj = {}
	obj.drawX = x
	obj.drawY = y
	obj.isOut = isOut
	obj.elements = 0
	obj.blocks = 0
	obj.rail = {}
	obj.station = {}
	obj.point = {}
	obj.next = {}

	return obj
end

function addBlockageForList(list, category, args)
	local blockList
	local obj
	
	if category == Category.rail then
		blockList = list.rail
		list.elements = list.elements + 1
		obj = RailBlock.new(list.elements, bit.blshift(1, table.maxn(blockList)), bit.blshift(1, list.blocks), args)
		list.blocks = list.blocks + 1
	elseif category  == Category.station then
		blockList = list.station
		list.elements = list.elements + 1
		obj = StationBlock.new(list.elements, bit.blshift(1, table.maxn(blockList)), bit.blshift(1, list.blocks), true, args)
		list.blocks = list.blocks + 1
	elseif category == Category.stationsub then
		blockList = list.station
		obj = StationBlock.new(list.elements, bit.blshift(1, table.maxn(blockList)), bit.blshift(1, list.blocks), false, args)
		list.blocks = list.blocks + 1
	elseif category == Category.point then
		blockList = list.point
		obj = Point.new(list.elements, bit.blshift(1, table.maxn(blockList)), args)
	elseif category == Category.next then
		blockList = list.next
		obj = Block.new("next", bit.blshift(1, table.maxn(blockList)))
		assert(table.maxn(blockList) < 1, string.format("Index Out Of Bounds (%s)", category))
	end
	assert(list.blocks < maxElement, string.format("Index Out Of Bounds (%s)", category))
	
	table.insert(blockList, obj)
end

--##Data##
local args = {...}
local configName = args and "config"
local cfg = loadConfig(configName)
local list = {}
for k, v in pairs(cfg) do
	local group = makeList(v.x, v.y, v.isOut)
	for k2, v2 in pairs(v.area) do
		addBlockageForList(list, v2.category, v2.args)
	end
end

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
		hour, min = math.modf(os.time())
		min = math.floor( min * 60 )
	
		if min > oldmin + 1 then
			oldmin = min
			rednet.send(65535, "retry")
			print("send retrymessage: "..hour.." : "..min)
		end
	end
end

rednet.close(modemSide)