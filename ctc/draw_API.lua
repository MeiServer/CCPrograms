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

Rectangle.new = function(name, startX, startY, goalX, goalY, pattern)
  local obj = {}
  obj.name = name
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

Rectangle.drawUpdate = function(self, pattern)
	self.pattern = pattern
	self:draw()
end

--##Panel##
local Panel = {}

Panel.new = function(recs, image, mon)
	local obj = {}
	obj.recs = recs
	obj.image = image
	obj.mon = mon
	
	return setmetatable(obj, {__index = Panel})
end

Panel.pp = function(self)
	print("Panel: image="..self.image)
	print("Rectangle: "..#self.recs)
	
	for i, v in ipairs(self.recs) do
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

--##API Function##
function makeRectangle(name, startX, goalX, startY, goalY, pattern)
	local str = (not name or name == nil) and "--" or name
	return Rectangle.new(str, startX, goalX, startY, goalY, pattern)
end

function makePanel(recs, image, mon)
	return Panel.new(recs, image, mon)
end