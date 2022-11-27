--name: OSBase
--author: niko__25
--version: 0.1

local OSBase = {}

--##Config##
OSBase.config = {
	pass = "pass",
	repeatPass = 0,
	usePass = false,
	isReceive = false,
	sendID = "",
	modemSide = "bottom",
	dataName = ""
}

--##Function
OSBase.new = function(mainfunc)
	local obj = {}
	obj.func = mainfunc
	obj.pre = nil
	obj.middle = nil
	obj.post = nil
	obj.data = nil
	return setmetatable(obj, {__index = OSBase})
end

OSBase.addData = function(self, tbl)
	for k, v in pairs(list) do
		if k == "pre" or k == "middle" or k == "post" then
			self[k] = v
		end
	end
end

OSBase.usePass = function(self, pass, num)
	self.config.usePass = true
	if type(pass) == "string" or type(pass) == "number" then
		if type(pass) == "number" then pass = tostring(pass) end
		self.config.pass = pass
	end
	if type(num) == "number" then
		self.config.repeatPass = num
	end
end

OSBase.useNet = function(self, id, data)
	assert(type(id) == "number", string.format(id.." is not number(%s)", type(id)))
	self.config.isReceive = true
	self.config.sendID = id
	self.config.dataName = data
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

OSBase.receiveData = function(self)
	local cfg = self.config
	rednet.open(cfg.modemSide)
	assert(rednet.isOpen(cfg.modemSide), string.format("rednet is not opend (%s)", cfg.modemSide))
	rednet.send(cfg.sendID, cfg.dataName)
	local event, id, data, distance = os.pullEvent("rednet_message")
	assert((id == cfg.sendID and data), "data is nil (or id is different)")
	assert(type(data) == "string", string.format("data is not string(%s)", type(data)))
	rednet.close(cfg.modemSide)
	if data == "retry" then
		-- if fail send data 
		self:receiveData()
	end
	return data
end

OSBase.main = function(self)
	local cfg = self.config
	self:preMain()
	if cfg.usePass then
		local isApprove = false
		local count = cfg.repeatPass
		while count > 0 or not isApprove do
			if self:checkPass()then
				break
			end
			count = count - 1
		end
		if not isApprove then
			break
		end
	end

	self:middleMain()
	
	if cfg.isReceive then
		self.data = self:receiveData()
	end
	
	if self.main then
		assert(self.func(self.data), "This program is not run")
	end

	self.clearOutput()
	self:postMain()
end

--##API##
function createOS(mainfunc)
	return OSBase.new(mainfunc)
end