-- It can be replaced by lfs

local FileMgr = require "FileMgr/FileMgrCommon"

function FileMgr:GetAllFileNameInDir(dir, bWithPath)
	if string.sub(dir, -1) == "/" then
		dir = string.sub(dir, 1, -2)
	end

	local fileNameTbl = {}
	local cmd = "dir "..dir
	local fh = io.popen(cmd)

	if string.sub(dir, -1) ~= "/" then
		dir = dir .. "/"
	end

	local candidateFileName

	for line in fh:lines() do
		-- print("raw", line)
		local time, info, fileName = string.match(line, "(%d%d%d%d/%d%d/%d%d%s+%d%d:%d%d)%s+[^%d^%w]+([%d%w,]+)[%s]+([^%s]+)")
		if time and info and fileName then

			--print("matched", time, info, fileName) 
			if info ~= "DIR" then
				candidateFileName = dir..fileName
				local realFile = io.open(candidateFileName, "r")
				
				if realFile then
					realFile:close()

					local outFileName
					if bWithPath then
						outFileName = dir..fileName
					else
						outFileName = fileName
					end
					table.insert(fileNameTbl, outFileName)
				end
			end
		end
	end

	fh:close()

	return fileNameTbl
end

function FileMgr:GetAllDirNameInDir(dir, bWithPath)
	if string.sub(dir, -1) == "/" then
		dir = string.sub(dir, 1, -2)
	end

	local fileNameTbl = {}
	local cmd = "dir "..dir
	local fh = io.popen(cmd)

	if string.sub(dir, -1) ~= "/" then
		dir = dir .. "/"
	end

	local candidateFileName

	for line in fh:lines() do
		local mattersCharacterIdx = string.find(line, "<DIR>")
		if mattersCharacterIdx and mattersCharacterIdx > 0 then
			local mattersCharacters = string.sub(line, mattersCharacterIdx+5)
			local fileName = string.match(mattersCharacters, "[%s]+([^%s]+)")
			if fileName then

				if bWithPath then
					candidateFileName = dir..fileName
				else
					candidateFileName = fileName
				end

				table.insert(fileNameTbl, candidateFileName)
			end
		end
		
	end

	fh:close()

	return fileNameTbl
end

function FileMgr:GetFileNameInDirByExtend(dir, extend)
	local fileNameTbl = {}

	if not extend then
		return fileNameTbl
	end

	if string.sub(extend, 1, 1) == "." then
		extend = string.sub(extend, 2)
	end

	local extendLen = #extend
	if extendLen <= 0 then
		return fileNameTbl
	end

	local allFilesTbl = self:GetAllFileNameInDir(dir)
	for _,fileName in pairs(allFilesTbl) do
		-- print(fileName, extendLen)
		if string.sub(fileName, -(extendLen+1)) == "."..extend then
			table.insert(fileNameTbl, fileName)
		else
			-- print(string.sub(fileName, -(extendLen+1)))
		end
	end

	return fileNameTbl

end

function FileMgr:GetBaseName(orignalName)
	local baseName,extend = string.match(orignalName, "([^%.]+)%.([^%.]+)")
	return baseName,extend
end

function FileMgr:RenameFile(dirName, orignalName, newName)
	if dirName and #dirName > 1 then
		if string.sub(dirName, -1) ~= "\\" then
			dirName = dirName .. "\\"
		end
	else
		dirName = ""
	end

	local cmd = [[ren "]]..dirName..orignalName..[[" "]]..newName..[["]]
	-- print(cmd)
	local fh = io.popen(cmd)
end

return FileMgr
