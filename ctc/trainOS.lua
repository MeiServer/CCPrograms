--##API##
os.loadAPI("OSBase")

function run(data)
	return shell.run("traindetec", data)
end

--##Main##
local osP = OSBase.createOS(run)
osP.config.modemSide = "bottom"
osP.config.sendID = ""

osP:main()
while rs.getInput("front") do
	osP:main()
end