--##API##
os.loadAPI("OSBase")

--##Main##
local osP = OSBase.createOS()
osP.config.program = "traindetec"
osP.config.modemSide = "bottom"
osP.config.sendID = ""

while rs.getInput("front") do
	osP:main()
end