--##API##
os.loadAPI("button_API")

--##Config##
local final railOut = "left"
local final stationOut = "right"
local final monOut = "top"
local final autoOut = "back"
local final autoColor = colors.white
local final maxBlockage = 16
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

function changeAuto(btn)
	if btn.isAuto then
		btn:drawUpdate(StateList.autoOff)
		rs.setBundledOutput(autoDir, 0)
	else
		btn:drawUpdate(StateList.autoOn)
		rs.setBundledOutput(autoDir, autoColor)
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
		
	rs.setBundledOutput(colors[1], railOut)
	rs.setBundledOutput(colors[2], stationOut)
end

function addBlockageForList(list, category, x, y)
	assert(table.maxn(list) < maxBlockage, "Index Out Of Bounds (Blockage)")
	
	local obj = {
		category = category,
		isManual = false,
		onPower = true,
		color = bit.blshift(1, table.maxn(list)),
		button = button_API.makeButton(color, x, x + 2, y, y, nil, StateList.default)
	}
	
	table.insert(list, obj)
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
local list = {}
addBlockageForList(list, "rail",  2,  7) -- 1
addBlockageForList(list, "rail",  8,  7) -- 2
addBlockageForList(list, "rail", 14,  7) -- 3
addBlockageForList(list, "rail", 20,  7) -- 4

local autoButton = {
	isAuto = false,
	button = button_API.makeButton("auto", 1, 2, 1, 2, nil, StateList.autoOff)
}

local btns = getButtons(list)
table.insert(btns, autoButton)

local mon = peripheral.wrap(monOut)
initialize(mon)
local panel = button_API.makePanel(btns, image, mon)
panel:draw()

while rs.getInput("front") do
	local event, btn, x, y = panel:pullButtonPushEvent(monOut)
	if btn.name ~= "auto" and autoButton.isAuto then
		onButtonPush(list, x, y)
	else
		changeAuto(autoButton)
	end
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()
