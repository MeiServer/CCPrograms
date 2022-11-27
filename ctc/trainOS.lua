--name: trainOS
--author: niko__25
--version: 0.1

--##API##
os.loadAPI("OSBase")

--##Function##
function run(data)
	return shell.run("test", data)
end

--##Main##
local osP = OSBase.createOS(run)
osP:useNet(157, "test")

while true do
	osP:main()
end