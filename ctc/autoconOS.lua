--##API##
os.loadAPI("OSBase")

--##Function##
function run(data)
	return shell.run("autocon", data)
end

--##Main##
local osP = OSBase.createOS(run)
osP:useNet(157, "test")

osP:main()
while rs.getInput("front") do
	osP:main()
end