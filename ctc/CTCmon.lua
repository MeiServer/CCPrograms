--##API##
os.loadAPI("tables")
os.loadAPI("draw_API")

--##Config##
local final monDir = "top"
local final detecDir = "left"
local final powerDir = "right"
local final manualDir = "back"
local final turnDir = "front"
local final image = "image"

--##State##
local StateList = {
	default = {colors.white},
	autoOn = {colors.yellow},
	autoOff = {colors.black},
	detecOn = {colors.lightBlue},
	powerOn = {[5] = colors.red},
	powerOFf = {[5] = colors.lime},
	manualOn = {[4] = colors.yellow},
	turnOn = {colors.orange},
	turnOff = {colors.blue}
}

--##Function##
function initialize(mon)
	assert(mon, "Monitor is not found")
	term.redirect(mon)
	term.clear()
	term.setCursorBlink(false)
	mon.setTextScale(1)
end

function blockUpdate(list, detecIn, powerIn, manualIn)
	local state
	for k, v in pairs(list) do
		if v.category ~= "turnout" then
			if colors.test(detecIn, v.blockColor) then
				state = StateList.detecOn
			else
				state = StateList.default
			end
			if colors.test(powerIn, v.bloclColor) then
				tables.overwrite(state, State.powerOn)
			else
				tables.overwrite(state, State.powerOff)
			end
			if colors.test(manualIn, v.bloclColor) then
				tables.overwrite(state, State.manualOn)
			end
			v.rec:drawUpdate(state)
		end
	end
end

function turnUpdate(list, turnIn)
	for k, v in pairs(list) do
		if v.category == "turnout" then
			if colors.test(turnIn, v.color) then
				v.rec:drawUpdate(StateList.turnOn)
			else
				v.rec:drawUpdate(StateList.turnOff)
			end
		end
	end
end

function autoUpdate(autoRec, turnIn)
	if colors.test(turnIn, colors.red) then
		autoRec:drawUpdate(StateList.autoOn)
	else
		autoRec:drawUpdate(StateList.autoOff)
	end
end

function onUpdate(list, detecIn, powerIn, manualIn, turnIn, auto)
	blockUpdate(list, detecIn, powerIn, manualIn)
	turnUpdate(list, turnIn)
	autoUpdate(auto, turnIn)
end

function addRectangleForList(list, x, y)
	local minX, maxX, y = x, x, y
	for k, v in pairs(list) do
		if type(v.name) == "number" then
			minX = x + 6 * (v.name - 1)
			maxX = minX + 4
		end
		
		if string.find(v.category, "station") then
			y = v.drawY
			
			if type(v.name) == "string" then
				minX = x + 6 * (tonumber(v.name:match("[%d]")) - 1)
				maxX = minX + 4
			end
		elseif v.category == "turnout" then
			minX, maxX = v.drawX, v.drawX
			y = v.drawY
		end
		
		v.rec = draw_API.makeRectangle(
			v.name, minX, maxX, y, y, StateList.default)
	end
	return list
end

function getBlockageMixList(list)
	local obj = {}
	for i, v in ipairs(list.rail) do
		obj[v.name] = v
	end
	for i, v in ipairs(list.station) do
		obj[v.name] = v
	end
	for i, v in ipairs(list.turnout) do
		obj[v.name] = v
	end
	return obj
end

function getRectangles(list)
	local recs = {}
	for k, v in pairs(list) do
		local rec = v.rec
		table.insert(recs, rec)
	end
	return recs
end

--##Main##
local list = tables.argsIntoTable(...)
list = addRectangleForList(getBlockageMixList(list), list.drawX, list.drawY)

local recs = getRectangles(list)
local autoRec = draw_API.makeRectangle("auto", 1, 2, 1, 2, StateList.autoOff)
table.insert(recs, autoRec)

local mon = peripheral.wrap(monDir)
initialize(mon)
local panel = draw_API.makePanel(recs, image, mon)
panel:draw()

while true do
	local detecIn = rs.getBundledInput(detecDir)
	local powerIn = rs.getBundledInput(powerDir)
	local manualIn = rs.getBundledInput(manualDir)
	local turnIn = rs.getBundledInput(turnDir)
	onUpdate(list, datecIn, powerIn, manualIn, turnIn, autoRec)
	
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()

