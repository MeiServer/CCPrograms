--##API##
os.loadAPI("OSBase")

--##Function##
function run(data)
	return shell.run("test", data)
end

--##Main##
local osP = OSBase.createOS(run)
osP:useNet(157, "test")

while rs.getInput("front") do
	osP:main()
end