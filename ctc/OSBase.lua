local OSBase = {}

--##Config##
OSBase.config = {
	pass = "pass",
	repeatPass = 0,
	usePass = false,
	isReseive = false,
	sendID = "",
	modemSide = "top",
	dataName = ""
}

--##Function
OSBase.new = function(mainfunc)
	local obj = {}
	obj.main = mainfunc
	obj.pre = nil
	obj.middle = nil
	obj.post = nil
	return setmetatable(obj, {__index = OSBase})
end

OSBase.addData = function(self, tbl)
	for k, v in pairs(list) do
		if k == "pre" or k == "middle" or k == "post" then
			self[k] = v
		end
	end
end


OSBase.clearAll = function()
	term.clear()
	term.setCursorPos(1, 1)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
end

OSBase.errPrint = function(...)
	term.setTextColor(colors.red)
	print(...)
	term.setTextColor(colors.white)
end

OSBase.slowPrintT = function(table, rate)
	local x, y = term.getCursorPos()
	for i, v in pairs(table) do
		textutils.slowPrint(v, rate)
		y = y + 1
	end
end

OSBase.clearOutput = function()
	local dir = {
		"front",
		"back",
		"top",
		"bottom",
		"right",
		"left"
	}
	
	for i, v in ipairs(dir) do
		rs.setBundledOutput(v, 0)
	end
end

OSBase.excution = function(obj)
	if obj then
		local tp = type(obj)
		if tp == "function" then
			obj()
		elseif tp == "string" or "number" then
			print(obj)
		elseif tp == "table" then
			for i, v in ipairs(obj) do
				OSBase.excution(v)
			end
		end
	end
end


OSBase.preMain = function(self)
	OSBase.excution(self.pre)
end

OSBase.middleMain = function(self)
	OSBase.excution(self.middle)
end

OSBase.postMain = function(self)
	OSBase.excution(self.post)
end

OSBase.checkPass = function(self)
	str = "Please enter your password"
	print(str)
	term.write(">>")
	if read() == self.config.pass then
		return true
	else
		self.errPrint("The password is incorrect")
		sleep(2)
		self.clearAll()
		return false
	end
end

OSBase.reseiveData = function(self)
	local cfg = self.config
	rednet.open(cfg.modemSide)
	if rednet.isOpen(cfg.modemSide) then
		if rednet.send(cfg.sendID, cfg.dataName, true) then
			local id, data, distance = os.pullEvent("rednet_message")
			if id == cfg.sendID and data then
				local tbl = textutils.unserialize(data)
				if type(tbl) == "table" then
					return tbl
				end
			end
		end
	end
end

OSBase.main = function(self)
	local cfg = self.config
	local data = nil
	self:preMain()
	if cfg.usePass then
		local count = cfg.repeatPass
		while count > 0 do
			if self:checkPass() then
				break
			end
			count = count - 1
		end
	end

	self:middleMain()
	
	if cfg.isReceive then
		data = self:receiveData()
	end
	
	if self.main then
		assert(self.main(), "This program is not run")
	end

	self.clearOutput()
	self:postMain()
end

--##API##
function createOS(mainfunc)
	return OSBase.new(mainfunc)
end