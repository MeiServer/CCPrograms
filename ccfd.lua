local args = {...}

local helpText = "usage: ccfd <FileName> <URL>"

function parseArgs(args)
	local obj = {
		outputFileName = assert(args[1], helpText),
		downloadUrl = assert(args[2], helpText)
	}
	return obj;
end

function openFile(fileName)
	local filePath = shell.resolve(fileName)
	local fileHandler = fs.open(filePath, "w")
	
	return assert(fileHandler, "Failed to open file: " .. fileName)
end

function openRemoteFile(url)
	local remoteFileHandler = http.get(url)
	
	return assert(remoteFileHandler, "Failed to open url: " .. url)
end

local parsedArgs = parseArgs(args)

local file = openFile(parsedArgs.outputFileName)
local remoteFile = openRemoteFile(parsedArgs.downloadUrl)

file.write(remoteFile.readAll())
file.flush()
file.close();
remoteFile.close()

print("done!")
