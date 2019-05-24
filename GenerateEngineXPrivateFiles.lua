require "Common/class"

local function runDemo_FolderEncode(bEncode)
	local encoder = require "Encode/FolderEncoder"
	local key = "xiaoxiao"
	local inputDirName = "E:/J/PhpStudyDir/x_code_deploy_dir"
	local includeFilter = ".lua"
	local excludeFilter = ".sherry"
	local encodeLen = 100
	local algrithmVersion = 1
	local outputFileName = "D:/Projects/x/deploy/encoded-codemgr-src/x_code_deploy_dir.sherryd"
	local bHandleSubFolder = true

	if bEncode == 1 or bEncode == true then
		encoder:EncodeFolderBinary(key, inputDirName, includeFilter, excludeFilter, encodeLen, algrithmVersion, outputFileName, bHandleSubFolder)
	else
		local inputFileName = "D:/Projects/x/deploy/encoded-codemgr-src/x_code_deploy_dir.sherryd"
		outputFileName = "D:/Projects/Test/out"
		encoder:DecodeFolderBinary(key, inputFileName, encodeLen, algrithmVersion, outputFileName)
	end
	
end

runDemo_FolderEncode(1)
