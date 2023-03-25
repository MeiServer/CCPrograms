function crearOutput()
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

while rs.getInput("front") do
	shell.run("powercontroller")
	crearOutput()
	print("reboot program")
end

