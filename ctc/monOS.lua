--##API##
os.loadAPI("OSBase")

--##Function##
function run(data)
	return shell.run("CTCmon", data)
end

--##Main##
local osP = OSBase.createOS(run)
osP:useNet(157, "test")

while true do
	osP:main()
end