--name: CTCmon
--author: niko__25
--version: 0.1.1
--add state color 5
--add change rectangleForList
--fix powerOFf poweroff
--change condition 'manual only draw powerOff'
--use tables.clone ()
--rename category
--rename Config
--supported In and Out line

--##API##
os.loadAPI("tables")
os.loadAPI("draw_API")

--##Config##
local final monSide = "top"
local final detecSide = "left"
local final powerSide = "right"
local final manualSide = "back"
local final pointSide = "front"
local final autoColor = colors.red
local final image = "image"

--##State##
local StateList = {
	default = {colors.white, colors.white
		, colors.white, colors.white, colors.white},
	autoOn = {colors.yellow},
	autoOff = {colors.black},
	detecOn = {colors.lightBlue, colors.lightBlue
		, colors.lightBlue, colors.lightBlue, colors.lightBlue},
	powerInOn = {[5] = colors.red},
	powerOutOn = {[1] = colors.red},
	powerInOff = {[5] = colors.lime},
	powerOutOff = {[1] = colors.lime},
	manualInOn = {[4] = colors.yellow},
	manualOutOn = {[2] = colors.yellow},
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

function blockUpdate(list, detecIn, powerIn, manualIn, isOut)
	local state = {}
	for k, v in pairs(list) do
		if v.category ~= "point" then
			state = tables.clone(StateList.default)
			if colors.test(detecIn, v.blockColor) then
				tables.overwrite(StateList.detecOn)
			end
			if colors.test(manualIn, v.blockColor) then
				if isOut then
					tables.overwrite(StateList.manualOutOn)
				else
					tables.overwrite(state, State.manualInOn)
				end
			end
			if colors.test(powerIn, v.blockColor) then
				if isOut then
					tables.overwrite(StateList.powerOutOn)
				else
					tables.overwrite(state, StateList.powerInOn)
				end
			elseif state[4] == colors.yellow then
				if isOut then
					tables.overwrite(StateList.powerOutOff)
				else
					tables.overwrite(state, StateList.powerInOff)
				end
			end
			v.rec:drawUpdate(state)
		end
	end
end

function turnUpdate(list, turnIn)
	for k, v in pairs(list) do
		if v.category == "point" then
			if colors.test(turnIn, v.color) then
				v.rec:drawUpdate(StateList.turnOn)
			else
				v.rec:drawUpdate(StateList.turnOff)
			end
		end
	end
end

function autoUpdate(autoRec, turnIn)
	if colors.test(turnIn, autoColor) then
		autoRec:drawUpdate(StateList.autoOn)
	else
		autoRec:drawUpdate(StateList.autoOff)
	end
end

function onUpdate(list, detecIn, powerIn, manualIn, turnIn, auto, isOut)
	blockUpdate(list, detecIn, powerIn, manualIn, isOut)
	turnUpdate(list, turnIn)
	autoUpdate(auto, turnIn)
end

function addRectangleForList(list, x, y)
	local maxNum = 0
	for k in pairs(list) do
		if type(k) == "number" and k > 0 then
			maxNum = k
		end
	end
	local t = {}
	for i = 0, maxNum - 1 do
		t[i + 1] = {
			minX = x + 6 * i,
			maxX = (x + 6 * i) + 2,
		}
	end

	for k, v in pairs(list) do
		local name = v.name
		if type(v.name) == "string" then
			name = tonumber(v.name:match("[%d]"))
		end
		if not isOut then
			name = maxNum - (name - 1)
		end
		if string.find(v.category, "station") then
			y = v.drawY
		end
		if v.category ~= "point" then
			v.rec = draw_API.makeRectangle(
			v.name, t[name].minX, t[name].maxX, y, y, StateList.default)
		else
			v.rec = draw_API.makeRectangle(
			v.name, v.drawX, v.drawY, v.drawY, v.drawY, StateList.turnOff)
		end
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
	for i, v in ipairs(list.point) do
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
local isOut = list.isOut
list = addRectangleForList(getBlockageMixList(list), list.drawX, list.drawY)

local recs = getRectangles(list)
local autoRec = draw_API.makeRectangle("auto", 1, 2, 1, 2, StateList.autoOff)
table.insert(recs, autoRec)

local mon = peripheral.wrap(monSide)
initialize(mon)
local panel = draw_API.makePanel(recs, image, mon)
panel:draw()

while true do
	local detecIn = rs.getBundledInput(detecSide)
	local powerIn = rs.getBundledInput(powerSide)
	local manualIn = rs.getBundledInput(manualSide)
	local turnIn = rs.getBundledInput(pointSide)
	onUpdate(list, detecIn, powerIn, manualIn, turnIn, autoRec, isOut)
	
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()

