
local local_config = require "_vedio_file_config"

local mime = require "Common/b64InLua"
local fileMgr = require "FileMgr/WindowsFileMgr"
local encoder = require "Encode/BigFileEncoder"

local dirName = local_config.dirName
local sizeThreshold = local_config.sizeThreshold
local encodeFlag = local_config.encodeFlag

local fileNames = fileMgr:GetAllFileNameInDir(dirName)
for k,v in pairs(fileNames) do
	local baseName,extend = fileMgr:GetBaseName(v)
	local fileSize = fileMgr:GetFileSize(dirName, v)

	if fileSize > sizeThreshold then
		if string.sub(baseName, 1, 3) == encodeFlag then

			encoder:DecodeFile(dirName, v)

			local realName = string.sub(baseName, 4)
			realName = string.gsub(realName, "%(", "=")
			realName = string.gsub(realName, "%)", "/")
			local newNameRaw = mime.unb64(realName)
			local newName = newNameRaw

			fileMgr:RenameFile(dirName, v, newName.."."..extend)
		end
		
	end
end
