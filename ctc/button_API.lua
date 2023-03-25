--name: button_API
--author: niko__25
--version: 0.1

--##Coordinate##
local Coordinate = {}

Coordinate.new = function(x, y)
	local obj = {}
	obj.x = x
	obj.y = y
	
	return setmetatable(obj, {__index = Coordinate})
end
Coordinate.pp = function(self) print(string.format("posX=%d, posY=%d", self.x, self.y)) end
	
Coordinate.width = function(startP, goalP) return math.abs(goalP.x - startP.x) + 1 end

Coordinate.height = function(startP, goalP) return math.abs(goalP.y - startP.y) + 1 end

Coordinate.midpoint = function(startP, goalP, floor_flag)
	local x = startP.x + startP:width(goalP)/2
	local y = startP.y + startP:height(goalP)/2
	if floor_flag then
    	return Coordinate.new(math.floor(x), math.floor(y))
	else
    	return Coordinate.new(x, y)
	end
end

--##Rectangle##
local Rectangle = {}

Rectangle.new = function(startX, startY, goalX, goalY, pattern)
  local obj = {}
  obj.start = Coordinate.new(startX, startY)
  obj.goal = Coordinate.new(goalX, goalY)
  obj.pattern = pattern
  
  return setmetatable(obj, {__index = Rectangle})
end

Rectangle.draw = function(self)
	local default = type(self.pattern) == "table" and self.pattern[1] or colors.gray
	term.setBackgroundColor(default)
	for y=self.start.y, self.goal.y do
		term.setCursorPos(self.start.x, y)
		local colortbl = self.pattern
		if #colortbl > 1 then
    		for i, color in ipairs(colortbl) do
    			term.setBackgroundColor(color)
    			term.write(" ")
			end
		else
			for x=self.start.x, self.goal.x do
      			term.write(" ")
			end
		end
	end
end

--##Button##
local Button = {}

Button.new = function(name, startX, goalX, startY, goalY, cmd, colorPattern)
	local obj = Rectangle.new(startX, startY, goalX, goalY, colorPattern)
	obj.name = name
	obj.cmd = cmd
	
	return setmetatable(obj, {__index = Button})
end

Button.pp = function(self)
	local str_cmd = self.cmd
	if type(self.cmd) == "function" then
		str_cmd = "a function"
	elseif not self.cmd then
		str_cmd = "do-nothing"
	end
	print(string.format("%s:(%d,%d)-(%d,%d), %s",
    	self.name, self.start.x, self.start.y, self.goal.x, self.goal.y, str_cmd))
end

Button.isWithin = function(self, point)
	local function within(n, start, goal)
		return n >= start and n <= goal
	end
	return within(point.x, self.start.x, self.goal.x) and within(point.y, self.start.y, self.goal.y)
end

Button.draw = function(self)
	Rectangle.draw(self)
end

Button.drawUpdate = function(self, newPattern)
	self.pattern = newPattern
	Rectangle.draw(self)
end

Button.evalCmd = function(self, ...)
  if not self.cmd or self.cmd == "" then
    return false
  elseif type(self.cmd) == "string" then
    return assert(loadstring(self.cmd), "invalid cmd: this string is invalid.")()
  elseif type(self.cmd) == "function" then
    return self:cmd(...)
  else
    return assert(false, "invalid cmd: cmd is function or function-string")
  end
end

Button.run = Button.evalCmd

--##Panel##
local Panel = {}

Panel.new = function(btns, image, mon)
	local obj = {}
	obj.btns = btns
	obj.image = image
	obj.mon = mon
	
	return setmetatable(obj, {__index = Panel})
end

Panel.pp = function(self)
	print("Panel: image="..self.image)
	print("  Buttons: "..#self.btns)
	
	for i, v in ipairs(self.btns) do
		print(#v)
		v:pp()
	end
end

Panel.draw = function(self)
	self.mon.setBackgroundColor(colors.gray)
	self.mon.clear()
	if self.image then
		local ig = paintutils.loadImage(self.image)
		paintutils.drawImage(ig, 1, 1)
	end
end

Panel.pullButtonPushEvent = function(self, mondir)
	local pushed_btn = false
	local whichButton = function(btns, x, y)
		for i ,v in ipairs(btns) do
			if v:isWithin(Coordinate.new(x, y)) then
				pushed_btn = v
				break
			end
		end
	end
 
	local pushX, pushY
 	repeat
		if self.mon.setTextScale then
			local event, dir, x, y = os.pullEvent("monitor_touch")
			if not mondir or mondir == dir  then
				whichButton(self.btns, x, y)
				pushX, pushY = x, y
			end
		else -- when self.mon is term
			local event, mouse, x, y = os.pullEvent("mouse_click")
			whichButton(self.btns, x, y)
			pushX, pushY = x, y
		end
	until  pushed_btn

	return "button_push", pushed_btn, pushX, pushY
end

Panel.addButton = function(self, btn)
	table.insert(self.btns, btn)
end

--##API Function##
function makeButton(name, startX, goalX, startY, goalY, cmd, pattern)
	local str = (not name or name == nil) and "--" or name
	return Button.new(str, startX, goalX, startY, goalY, cmd, pattern)
end

function makeButtons(list)
	local buttons = {}
	for i, v in pairs(list) do
		local obj = makeButton(v.name or i, v.startX, v.goalX, v.startY, v.goalY, v.cmd, v.pattern)
		table.insert(buttons, obj)
	end
	return buttons
end

function makePanel(btns, image, mon)
	return Panel.new(btns, image, mon)
end
