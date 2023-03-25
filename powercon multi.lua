--name: powercon
--author: niko__25
--version: 0.1.1
--add manual signal
--rename category
--rename Config

--##API##
os.loadAPI("button_API")
os.loadAPI("tables")

--##Config##
local final areaSide = "left"
local final pointSide = "front"
local final monSide = "top"
local final manualSide = "right"
local final autoSide = "back"
local final autoColor = colors.white
local final image = "image"
local final StateList = {
	default = {colors.white},
	powerInOn = {colors.white, colors.yellow, colors.green},
	powerInOff = {colors.white, colors.yellow, colors.red},
	powerOutOn = {colors.green, colors.yellow, colors.white},
	powerOutOff = {colors.red, colors.yellow, colors.white},
	autoOn = {colors.yellow},
	autoOff = {colors.black},
	turnOn = {colors.orange},
	turnOff = {colors.blue},
	reboot = {colors.red, colors.green, colors.blue, colors.yellow}
}

--##Function##
function initialize(mon)
	assert(mon, "Monitor is not found")
	term.redirect(mon)
	term.clear()
	term.setCursorBlink(false)
	mon.setTextScale(1)
end

function initData(list)
	rs.setBundledOutput(areaSide, 0)
	rs.setBundledOutput(autoSide, 0)
	for k, v in pairs(list) do
		if v.category ~= "point" then
			v.isManual = false
			v.onPower = true
			v.button:drawUpdate(StateList.default)
		end
	end
end

function changeAuto(tbl)
	if tbl.isAuto then
		tbl.button:drawUpdate(StateList.autoOff)
		rs.setBundledOutput(autoSide, 0)
		tbl.isAuto = not tbl.isAuto
		return true
	else
		tbl.button:drawUpdate(StateList.autoOn)
		rs.setBundledOutput(autoSide, autoColor)
		tbl.isAuto = not tbl.isAuto
		return false
	end
end

function onButtonPush(list, pushX, pushY, isAuto, isOut)
	for k, v in pairs(list) do
		local powerX = isOut and v.button.start.x or v.button.goal.x
		local manualX = v.button.start.x + 1
		if v.category ~= "point" then
			if isAuto then
				if powerX == pushX and v.button.start.y == pushY then
					if v.isManual then
						v.onPower = not v.onPower
						drawBlock(v, isOut)
					end
				elseif manualX == pushX and v.button.start.y == pushY then
					v.isManual = not v.isManual
					if not v.isManual then
						v.onPower = true
					end
					drawBlock(v, isOut)
				end
			end
		else
			if powerX == pushX and v.button.start.y == pushY then
				v.onPower = not v.onPower
				drawPoint(v)
			end
		end
	end
end

function drawBlock(tbl, isOut)
	if tbl.isManual then
		local state = isOut and StateList.powerOutOn or StateList.powerInOn
		if tbl.onPower then
			tbl.button:drawUpdate(state)
		else
			state = isOut and StateList.powerOutOff or StateList.powerInOff
			tbl.button:drawUpdate(state)
		end
	else
		tbl.button:drawUpdate(StateList.default)
	end
end

function drawPoint(tbl)
	if tbl.onPower then
		tbl.button:drawUpdate(StateList.turnOff)
	else
		tbl.button:drawUpdate(StateList.turnOn)
	end
end

function onUpdate(list, x, y, isAuto, isOut)
	onButtonPush(list, x, y, isAuto, isOut)
	
	local colors = {power = 0, point = 0, manual = 0}
	
	for k, v in pairs(list) do
		if v.category == "point" then
			if not v.onPower then
				colors.point = colors.point + v.color
			end
		else
			if not v.onPower then
				colors.power = colors.power + v.blockColor
			end
			if v.isManual then
				colors.manual = colors.manual + v.blockColor
		end
	end
		
	rs.setBundledOutput(areaSide, colors.power)
	rs.setBundledOutput(manualSide, colors.manual)
	rs.setBundledOutput(pointSide, colors.point)
end

function addButtonForList(list, x, y)
	local maxNum = 0
	for k in pairs(list) do
		if type(k) == "number" and k > 0 then
			maxNum = k
		end
	end
	local t = {}
	for i = 0, maxNum - 1 do
		t[i + 1] = {
			minX = x + 4 * i,
			maxX = (x + 4 * i) + 2,
		}
	end

	for k, v in pairs(list) do
		local name = v.name
		if type(v.name) == "string" then
			name = tonumber(v.name:match("[%d]"))
		end
		if isOut then
			name = maxNum - (name - 1)
		end
		if string.find(v.category, "station") then
			y = v.drawY
		end
		if v.category == "point" then
			v.button = button_API.makeButton(
			v.name, v.drawX, v.drawX, v.drawY, v.drawY, nil, StateList.default)
		else
			v.button = button_API.makeButton(
			v.name, t[name].minX, t[name].maxX, y, y, nil, StateList.default)
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

function getButtons(list)
	local btns = {}
	for k, v in pairs(list) do
		local btn = v.button
		table.insert(btns, btn)
	end
	return btns
end


--##Main##
local list = tables.argsIntoTable(...)
local isOut = list.isOut
list = addButtonForList(getBlockageMixList(list), list.drawX, list.drawY, list.isOut)

local btns = getButtons(list)
local autoButton = {
	isAuto = false,
	button = button_API.makeButton("auto", 1, 2, 1, 2, nil, StateList.autoOff)
}
table.insert(btns, autoButton.button)
local mon = peripheral.wrap(monSide)
initialize(mon)
local x, y = term.getSize()
local rebootButton = button_API.makeButton("reboot", 1, 2, y - 1, y, nil, StateList.reboot)
table.insert(btns, rebootButton)
local panel = button_API.makePanel(btns, image, mon)
panel:draw()

while true do
	local event, btn, x, y = panel:pullButtonPushEvent(monSide)
	if btn.name == "auto" then
		if changeAuto(autoButton) then
			initData(list)
		end
	elseif btn.name == "reboot" then
		break
	else
		onUpdate(list, x, y, autoButton.isAuto, isOut)
	end
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()