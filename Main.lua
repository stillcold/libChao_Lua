require "Common/class"

local function runDemo_UrlAnalysisMgr( ... )
	local UrlAnalysisMgr = require "UrlAnalysis/UrlAnalysisMgr"

	local oriServerId2RealServerId, totalCount, mergeCount = UrlAnalysisMgr:AnalysisServerList("https://www.baidu.com")
	print(oriServerId2RealServerId[1], totalCount, mergeCount, totalCount - mergeCount)
end

local function runDemo_Encode()
	local encoder = require "Encode/SheeryEncoder"
	-- In many place, mime just doesn't work!!!
	-- I have to use this instead
	local mime = require "Common/b64InLua"

	encoder:SetKey("test", 100)
	local encoded1 = encoder:Encode([==[haode long long ago, there is a very dog, it's name is xiaoxiao]==])
	local encoded2 = encoder:Encode("yoxi")
	print(encoded1)
	print(encoded2)
	encoder:SetKey("test", 100)
	local decoded1 = encoder:Decode(mime.unb64(encoded1))
	local decoded2 = encoder:Decode(mime.unb64(encoded2))
	print(decoded1)
	print(decoded2)

	-- encoder:EncodeFileBinary("testPic.gif", "Main.lua")
	-- encoder:EncodeFileBinary("testPic.gif", "testPic.gif")
	-- encoder:DecodeBinaryFile("testPic.gif", "testPic.gif.sherry", "testPic.gif.sherry.gif")
	-- encoder:DecodeBinaryFile("testPic.gif", "Main.lua.sherry", "Main.lua.sherry.lua")
end

local function runDemo_SimpleLuaSocket()
	local simpleLuaSocket = require "Net/SimpleLuaSocket"

	local socket = simpleLuaSocket:SocketConnect("127.0.0.1", 80)
	simpleLuaSocket:SocketSend(socket, "hi")
	print(simpleLuaSocket:SocketRecieve(socket))
	simpleLuaSocket:SocketClose(socket)
end


local function runDemo_BigFile_Encode()
	local encoder = require "Encode/BigFileEncoder"
	-- encoder:EncodeFile(nil, "RMB_002.png")
	-- encoder:DecodeFile(nil, "RMB_002.png")
end

local function runDemo_FileMgr()

	local mime = require "Common/b64InLua"
	local fileMgr = require "FileMgr/WindowsFileMgr"
	local dirName = [[N:\test]]
	local fileNames = fileMgr:GetFileNameInDirByExtend(dirName, "png")
	for k,v in pairs(fileNames) do
		-- print(k,v)
		local baseName,extend = fileMgr:GetBaseName(v)
		local fileSize = fileMgr:GetFileSize(dirName, v)
		print("size is ", fileSize)
		local newNameRaw = mime.b64(baseName)
		local newName = string.gsub(newNameRaw,"=", "(")
		print(baseName, newName)
		fileMgr:RenameFile(dirName, v, newName.."."..extend)
	end

	local dirNames = fileMgr:GetAllDirNameInDir("./")
	for k,v in pairs(dirNames) do
		print(k,v)
	end

end

local function runDemo_SafeCall()
	require "Common/safecall"
	local mime = require "Common/b64InLua"

	local ret = SAFE_CALL(mime.b64, "test")
	print(ret)
end

local function runDemo_BILogReader()
	local reader = require "LogAnalysis/BILogReader.lua"
	local contentTbl = reader.readFile("sample.log")
	for k,v in pairs(contentTbl) do
		print(k,v)
	end
end

local function runDemo_HuffmanWeightTbl()
	local huffmanWeightTbl = require "Common/huffmanWeightTbl"
	huffmanWeightTbl:__Test_Suite()
end

local function runDemo_FactoryMethod()
	require "DesignPattern/FactoryMethod"
	FactoryMethodMain()
end

local function runDemo_FolderEncode()
	local encoder = require "Encode/FolderEncoder"
	local key = "xiaoxiao"
	local inputDirName = "test/Folder"
	local includeFilter = nil -- ".txt"
	local excludeFilter = ".log"
	local encodeLen = 100
	local algrithmVersion = 1
	local outputFileName = nil

	local inputFileName = "test/Folder.sherryd"

	local bEncode = 1
	if bEncode == 1 then
		encoder:EncodeFolderBinary(key, inputDirName, includeFilter, excludeFilter, encodeLen, algrithmVersion, outputFileName)
	else
		outputFileName = "test/out"
		encoder:DecodeFolderBinary(key, inputFileName, encodeLen, algrithmVersion, outputFileName)
	end
	
end

-- runDemo_UrlAnalysisMgr()
-- runDemo_Encode()
-- runDemo_FileMgr()
-- runDemo_SafeCall()
-- runDemo_BigFile_Encode()
-- runDemo_BILogReader()
-- runDemo_HuffmanWeightTbl()
-- runDemo_FactoryMethod()
runDemo_FolderEncode()