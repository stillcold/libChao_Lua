require "Common/class"

local function runDemo_FolderEncode()
	local encoder = require "Encode/FolderEncoder"
	local key = "xiaoxiao"
	-- local inputDirName = "D:/Projects/x/deploy/encoded-codemgr-src/x_code_deploy_dir/keywords"
	local inputDirName = "D:/Projects/x/deploy/encoded-codemgr-src/x_code_deploy_dir"
	local includeFilter = ".lua"
	local excludeFilter = ".sherry"
	local encodeLen = 100
	local algrithmVersion = 1
	local outputFileName = nil
	local bHandleSubFolder = true

	local bEncode = 10
	if bEncode == 1 then
		encoder:EncodeFolderBinary(key, inputDirName, includeFilter, excludeFilter, encodeLen, algrithmVersion, outputFileName, bHandleSubFolder)
	else
		-- local inputFileName = "D:/Projects/x/deploy/encoded-codemgr-src/x_code_deploy_dir/keywords.sherryd"
		local inputFileName = "D:/Projects/x/deploy/encoded-codemgr-src/x_code_deploy_dir.sherryd"
		outputFileName = "D:/Projects/Test/out"
		encoder:DecodeFolderBinary(key, inputFileName, encodeLen, algrithmVersion, outputFileName)
	end
	
end

runDemo_FolderEncode()
