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
	powerOn = {colors.green, colors.yellow, colors.white},
	powerOff = {colors.red, colors.yellow, colors.white},
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

function onButtonPush(list, pushX, pushY, isAuto)
	for k, v in pairs(list) do
		local posX, posY = v.button.start.x, v.button.start.y
		if v.category ~= "turnout" then
			if isAuto then
				if posX == pushX and posY == pushY then
					if v.isManual then
						v.onPower = not v.onPower
						drawBlock(v)
					end
				elseif (posX + 1) == pushX and posY == pushY then
					v.isManual = not v.isManual
					if not v.isManual then
						v.onPower = true
					end
					drawBlock(v)
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

function drawBlock(tbl)
	if tbl.isManual then
		if tbl.onPower then
			tbl.button:drawUpdate(StateList.powerOn)
		else
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

function onUpdate(list, x, y, isAuto)
	onButtonPush(list, x, y, isAuto)
	
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

function addButtonForList(list, x, y)
	local minX, maxX, y = x, x, y
	for k, v in pairs(list) do
		if type(v.name) == "number" then
			minX = x + 4 * (v.name - 1)
			maxX = minX + 2
		end
		
		if string.find(v.category, "station") then
			y = v.drawY
			
			if type(v.name) == "string" then
				minX = x + 4 * (tonumber(v.name:match("[%d]")) - 1)
				maxX = minX + 2
			end
		elseif v.category == "turnout" then
			minX, maxX = v.drawX, v.drawX
			y = v.drawY
		end
		
		v.button = button_API.makeButton(
			v.name, minX, maxX, y, y, nil, StateList.default)
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
list = addButtonForList(getBlockageMixList(list), list.drawX, list.drawY)

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
		onUpdate(list, x, y, autoButton.isAuto)
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
