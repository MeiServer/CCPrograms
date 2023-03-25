--name: powercon
--author: niko__25
--version: 0.1

--##API##
os.loadAPI("button_API")
os.loadAPI("tables")

--##Config##
local final blockDir = "left"
local final turnoutDir = "front"
local final monDir = "top"
local final manualDir = "right"
local final autoDir = "back"
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
	rs.setBundledOutput(railDir, 0)
	rs.setBundledOutput(stationDir, 0)
	rs.setBundledOutput(autoDir, 0)
	for k, v in pairs(list) do
		if v.category ~= "turnout" then
			v.isManual = false
			v.onPower = true
			v.button:drawUpdate(StateList.default)
		end
	end
end

function changeAuto(tbl)
	if tbl.isAuto then
		tbl.button:drawUpdate(StateList.autoOff)
		rs.setBundledOutput(autoDir, 0)
		tbl.isAuto = not tbl.isAuto
		return true
	else
		tbl.button:drawUpdate(StateList.autoOn)
		rs.setBundledOutput(autoDir, autoColor)
		tbl.isAuto = not tbl.isAuto
		return false
	end
end

function onButtonPush(list, pushX, pushY, isAuto, isOut)
	for k, v in pairs(list) do
		local powerX = isOut and v.button.start.x or v.button.goal.x
		local manualX = v.button.start.x + 1
		if v.category ~= "turnout" then
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
			if posX == pushX and posY == pushY then
				v.onPower = not v.onPower
				drawTurnout(v)
			end
		end
	end
end

function drawBlock(tbl, isOut)
	if tbl.isManual then
		local state = isOut and StateList.powerOutOn or StateList.powerInOn
		if tbl.onPower then
			tbl.button:drawUpdate(StateList.powerOn)
		else
			state = isOut and StateList.powerOutOff or StateList.powerInOff
			tbl.button:drawUpdate(StateList.powerOff)
		end
	else
		tbl.button:drawUpdate(StateList.default)
	end
end

function drawTurnout(tbl)
	if tbl.onPower then
		tbl.button:drawUpdate(StateList.turnOff)
	else
		tbl.button:drawUpdate(StateList.turnOn)
	end
end

function onUpdate(list, x, y, isAuto, isOut)
	onButtonPush(list, x, y, isAuto, isOut)
	
	local colors = {[1] = 0, [2] = 0}
	
	for k, v in pairs(list) do
		if v.category == "turnout" then
			if not v.onPower then
				colors[2] = colors[2] + v.blockColor
			end
		else
			if not v.onPower then
				colors[1] = colors[1] + v.blockColor
			end
		end
	end
		
	rs.setBundledOutput(blockDir, colors[1])
	rs.setBundledOutput(turnoutDir, colors[2])
end

function addButtonForList(list, x, y, isOut)
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
			maxX = minX + 2,
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
		if v.category == "turnout" then
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
	for i, v in ipairs(list.turnout) do
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
list = addButtonForList(getBlockageMixList(list), list.drawX, list.drawY, list.isOut)

local btns = getButtons(list)
local autoButton = {
	isAuto = false,
	button = button_API.makeButton("auto", 1, 2, 1, 2, nil, StateList.autoOff)
}
table.insert(btns, autoButton.button)
local mon = peripheral.wrap(monDir)
initialize(mon)
local rebootButton = {
	local x, y = term.getSize()
	button = button_API.makeButton("reboot", 1, 2, y - 1, y, nil, StateList.reboot)
}
table.insert(btns, rebootButton.button)
local panel = button_API.makePanel(btns, image, mon)
panel:draw()

while rs.getBundledInput(turnoutDir, colors.black) do
	local event, btn, x, y = panel:pullButtonPushEvent(monDir)
	if btn.name ~= "auto" and btn.name ~= "reboot" then
		onUpdate(list, x, y, autoButton.isAuto, list.isOut)
	elseif btn.name == "auto" then
		if changeAuto(autoButton) then
			initData(list)
		end
	elseif btn.name == "reboot" then
		break
	end
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()
