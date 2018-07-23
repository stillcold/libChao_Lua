

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
	-- encoder:EncodeFile("temp_test2.gif")
	-- encoder:DecodeFile("temp_test2.gif")
end

local function runDemo_FileMgr()

	local mime = require "Common/b64InLua"
	local fileMgr = require "FileMgr/WindowsFileMgr"
	local files = fileMgr:GetFileNameInDirByExtend("./", "txt")
	for k,v in pairs(files) do
		print(k,v)
		local baseName,extend = fileMgr:GetBaseName(v)
		local newNameRaw = mime.b64(baseName)
		local newName = string.gsub(newNameRaw,"=", "(")
		fileMgr:RenameFile(v, newName.."."..extend)
	end

	local files = fileMgr:GetAllDirNameInDir("./")
	for k,v in pairs(files) do
		print(k,v)
	end

end

-- runDemo_UrlAnalysisMgr()
-- runDemo_Encode()
runDemo_FileMgr()