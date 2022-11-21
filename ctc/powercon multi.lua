--##API##
os.loadAPI("button_API")
os.loadAPI("strings")
os.loadAPI("tables")

--##Config##
local final railir = "left"
local final stationDir = "right"
local final monDir = "top"
local final autoDir = "back"
local final autoColor = colors.white
local final image = "image"
local final StateList = {
	default = {colors.white},
	powerOn = {colors.green, colors.yellow, colors.white},
	powerOff = {colors.red, colors.yellow, colors.white},
	autoOn = {colors.yellow},
	autoOff = {colors.black}
}

--##Function##
function initialize(mon)
	assert(mon, "Monitor is not found")
	term.redirect(mon)
	term.clear()
	term.setCursorBlink(false)
	mon.setTextScale(1)
end

function changeAuto(tbl)
	if tbl.isAuto then
		tbl.button:drawUpdate(StateList.autoOff)
		rs.setBundledOutput(autoOut, 0)
		tbl.isAuto = not tbl.isAuto
		return true
	else
		tbl.button:drawUpdate(StateList.autoOn)
		rs.setBundledOutput(autoDir, autoColor)
		tbl.isAuto = not tbl.isAuto
		return false
	end
end

function onButtonPush(list, pushX, pushY)
	for i, v in ipairs(list) do
		local posX, posY = v.button.start.x, v.button.start.y
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

function onUpdate(list, x, y)
	onButtonPush(list, x, y)
	
	local colors = {[1] = 0, [2] = 0}
	
	for i, v in ipairs(list) do
		local num = 1
		if v.category == "station" then
			num = 2
		end
		
		if not v.onPower then
			colors[num] = colors[num] + v.color
		end
	end
		
	rs.setBundledOutput(colors[1], railDir)
	rs.setBundledOutput(colors[2], stationDir)
end

function addButtonForList(list, x, y)
	local posX, posY = x, y
	for i, v in ipairs(list) do
		if string.find(v.category, "station") then
			posY = v.drawY
		end
		
		if type(v.name) == "string" then
			local s = strings.split(v.name, "-")
			posX = tonumber(s[1])
		else
			posX = x + 4 * (v.name - 1)
		end
		
		v.button = button_API.makeButton(
			v.name, posX, posX + 2, y, y, nil, StateList.default)
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
	return obj
end

function getButtons(list)
	local btns = {}
	for i, v in ipairs(list) do
		local btn = v.button
		table.insert(btns, btn)
	end
	return btns
end


--##Main##
local list = tables.argsIntoTable(...)
list = addButtonForList(getBlockageMixList(list), list.drawX, list.drawY)


local autoButton = {
	isAuto = false,
	button = button_API.makeButton("auto", 1, 2, 1, 2, nil, StateList.autoOff)
}

local btns = getButtons(list)
table.insert(btns, autoButton.button)

local mon = peripheral.wrap(monDir)
initialize(mon)
local panel = button_API.makePanel(btns, image, mon)
panel:draw()

while rs.getInput("front") do
	local event, btn, x, y = panel:pullButtonPushEvent(monDir)
	if btn.name ~= "auto" and autoButton.isAuto then
		onButtonPush(list, x, y)
	elseif btn.name == "auto" then
		if changeAuto(autoButton) then
			break
		end
	end
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()
