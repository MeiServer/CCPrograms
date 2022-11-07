--##Config##
local final outputDir = "left"
local final image = "image"
local final Time = 3
local final limit = 10

--##Function##
function drawBlockage(mon)
	paintutils.drawPixel(1, 1, 128)
	local ig = paintutils.loadImage(image)
	paintutils.drawImage(ig, 1, 1)
end

function initialize(mon)
	if mon ~= nil then
		term.redirect(mon)
		term.clear()
		mon.setTextScale(1)
	end
end

function addDataForList(list, x, y)
	local obj = {
		minX = x,
		minY = y,
		maxX = x + 4,
		maxY = y
	}
	
	table.insert(list, obj)
end

function addTurnoutForList(list, x, y, setblock, turnblock)
	local obj = {
		x = x,
		y = y,
		setblock = setblock,
		turnblock = turnblock
	}
	
	table.insert(list, obj)
end

function getBranchList(turnout, route)
	local branch = {}
	
	for i, v in ipairs(route) do
		local isBranch = false
		
		for i2, v2 in ipairs(v) do
			for i3, v3 in ipairs(turnout) do
				if v3.setblock == v2 then
					isBranch = true
				elseif v3.turnblock == v2 and isBranch then
					branch[i2 - 1] = i3
					isBranch = false
				end
			end
		end
	end
	return branch
end			

function addTrainrouteForList(list, ...)
	local obj = {...}

	if obj then
		table.insert(list, obj)
	end
end

function getDiagram(list, limit)
	local tbl = {}
	
	for i=1, limit do
		local str = ""
		local empty = true
		
		for i2, v in ipairs(list) do
			if str ~= "" then
				str = str .. ","
			end
			
			if v[i] ~= nil then
			str = str .. tostring(v[i])
			empty = false
			end
		end
		
		if empty then break end
		
		table.insert(tbl, str)
	end
	return tbl
end
			
--##Main##
os.loadAPI("strings")
os.loadAPI("tables")
local mon = peripheral.wrap(outputDir)
initialize(mon)
drawBlockage(mon)

local list = {}
addDataForList(list,  2,  7) -- 1
addDataForList(list,  8,  7) -- 2
addDataForList(list, 14,  7) -- 3
addDataForList(list, 20,  7) -- 4
addDataForList(list, 26,  7) -- 5
addDataForList(list, 26,  3) -- 6
addDataForList(list, 32,  7) -- 7
addDataForList(list, 38,  7) -- 8
addDataForList(list, 44,  7) -- 9
addDataForList(list, 50,  7) --10
addDataForList(list,  2, 11) --11
addDataForList(list,  8, 11) --12
addDataForList(list, 14, 11) --13
addDataForList(list, 20, 11) --14
addDataForList(list, 26, 11) --15
addDataForList(list, 26, 15) --16
addDataForList(list, 32, 11) --17
addDataForList(list, 38, 11) --18
addDataForList(list, 44, 11) --19
addDataForList(list, 50, 11) --20

local turnout = {}
addTurnoutForList(turnout, 24,  8,  4,  6)
addTurnoutForList(turnout, 32, 10, 17, 16)

local trainroute = {}
addTrainrouteForList(trainroute,  1,  2,  3,  4,
	5,  7,  8,  9, 10, 12)
addTrainrouteForList(trainroute,  4,  6,  6,  6,
	7,  8,  9, 10, 12, 13)
addTrainrouteForList(trainroute,  8,  9, 10, 19,
	18, 17, 15, 14, 13, 12)
addTrainrouteForList(trainroute, 19, 18, 17, 16,
	16, 14, 13, 12,  1,  2)
addTrainrouteForList(trainroute, 16, 14, 13, 12,
	11,  1,  2,  3,  4,  5)

local diagram = getDiagram(trainroute, limit)

local branch = getBranchList(turnout, trainroute)


while rs.getInput("back") do
	
	for i, v in ipairs(diagram) do
		drawBlockage(mon)
		local tbl = strings.split(v, ",")
		
		for i2, v2 in ipairs(tbl) do
			local num = tonumber(v2)
			local bk = list[num]
			paintutils.drawLine(bk.minX, bk.minY, bk.maxX, bk.maxY, colors.lightBlue)
			--print(string.format("draw(lightBlue): block= %d", num))
			
		end
		
		if branch and tables.in_key(branch, i) then
			local tbl2 = turnout[branch[i]]
			--print(string.format("draw(orange): x= %d, y= %d", tbl2.x, tbl2.y))
			paintutils.drawPixel(tbl2.x, tbl2.y, colors.orange)
		end
		sleep(Time)
		
		if not rs.getInput("back") then
			term.restore()
			return
		end
	end
	sleep(0)
end

paintutils.drawPixel(1, 1, 128)
term.restore()