-- It can be replaced by lfs

local FileMgr = {}

function FileMgr:GetFileSize(dirName, fileName)

	if dirName and #dirName > 1 then
		if string.sub(dirName, -1) ~= "\\" then
			dirName = dirName .. "\\"
		end
	else
		dirName = ""
	end

	local file = io.open(dirName..fileName, "rb")
	if not file then return end
	local size = file:seek("end")
	file:close()
	return size
end

return FileMgr
