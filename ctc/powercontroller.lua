--##API##
os.loadAPI("button_API")

--##Config##
local final railOut = "left"
local final stationOut = "right"
local final monOut = "top"
local final maxBlockage = 16
local final image = "image"
local final StateList = {
	default = {colors.white},
	powerOn = {colors.green, colors.yellow, colors.white},
	powerOff = {colors.red, colors.yellow, colors.white}
}

--##Function##
function initialize(mon)
	if mon ~= nil then
		term.redirect(mon)
		term.clear()
		term.setCursorBlink(false)
		mon.setTextScale(1)
	end
end

function onButtonPush(list, pushX, pushY)
	for i, v in ipairs(list) do
		if v.x == pushX and v.y == pushY then
			if v.isManual then
				v.onPower = v,onPower and false or true
				drawBlock(v)
			end
		elseif v.x + 1 == pushX and v.y == pushY then
			v.isManual = v.isManual and false or true
			drawBlock(v)
		end
	end
end

function drawBlock(tbl)
	if tbl.isManual then
		if tbl.onPower then
			v.button:drawUpdate(StateList.powerOn)
		else
			v.button:drawUpdate(StateList.powerOff)
		end
	else
		v.button:drawUpdate(StateList.default)
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

local btns = getButtons(list)

local mon = peripheral.wrap(monOut)
initialize(mon)
local panel = button_API.makePanel(btns, image, mon)
panel:draw()

while rs.getInput("front") do
	local event, btn, x, y = panel:pullButtonPushEvent(monOut)
	onButtonPush(list, x, y)
	sleep(0)
end

term.setBackgroundColor(colors.gray)
term.setCursorBlink(true)
term.restore()