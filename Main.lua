local UrlAnalysisMgr = require "UrlAnalysis/UrlAnalysisMgr"
local encoder = require "Encode/SheeryEncoder"
-- In many place, mime just doesn't work!!!
-- I have to use this instead
local mime = require "Common/b64InLua"

local function runDemo_UrlAnalysisMgr( ... )
	local oriServerId2RealServerId, totalCount, mergeCount = UrlAnalysisMgr:AnalysisServerList("https://www.baidu.com")
	print(oriServerId2RealServerId[1], totalCount, mergeCount, totalCount - mergeCount)
end

local function runDemo_Encode()
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

	encoder:EncodeFile("test", "main.lua")
	encoder:DecodeFile("test", "main.lua.sherry")
end


print(mime.b64("hah"))

-- runDemo_UrlAnalysisMgr()
runDemo_Encode()