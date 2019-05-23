-- It can be replaced by lfs

local FileMgr = require "FileMgr/FileMgrCommon"

function FileMgr:GetAllFileNameInDir(dir, bWithPath)
	if string.sub(dir, -1) == "/" then
		dir = string.sub(dir, 1, -2)
	end

	dir = string.gsub(dir, "/", "\\")

	local fileNameTbl = {}
	local cmd = "dir "..dir
	local fh = io.popen(cmd)

	dir = string.gsub(dir, "\\", "/")

	if string.sub(dir, -1) ~= "/" then
		dir = dir .. "/"
	end

	local candidateFileName

	for line in fh:lines() do
		-- local time, info, fileName = string.match(line, "(%d%d%d%d/%d%d/%d%d%s+%d%d:%d%d)%s+[^%d^%w]+([%d%w,]+)[%s]+([^%s]+)")
		local time, info, fileName = string.match(line, "(%d%d%d%d/%d%d/%d%d%s+%d%d:%d%d)%s+[^%d^%w]+([%d%w,]+)[%s]+(.+)")
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

-- bSkipFakeSubFolder -> 是否跳过 .. 和 . 这样的 *伪* 子文件夹
function FileMgr:GetAllDirNameInDir(dir, bWithPath, bSkipFakeSubFolder)
	if string.sub(dir, -1) == "/" then
		dir = string.sub(dir, 1, -2)
	end

	local fileNameTbl = {}

	dir = string.gsub(dir, "/", "\\")
	local cmd = "dir "..dir
	local fh = io.popen(cmd)

	dir = string.gsub(dir, "\\", "/")

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

				if not bSkipFakeSubFolder or string.sub(fileName, -1) ~= "." then
					table.insert(fileNameTbl, candidateFileName)
				end
				
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

	local subString = orignalName

	local pointPos = string.find(subString, "%.")

	local cutLen = 0
	local lastMatch = pointPos

	while pointPos do
		subString = string.sub(subString, pointPos + 1)
		cutLen = cutLen + pointPos
		lastMatch = cutLen
		pointPos = string.find(subString, "%.")
	end

	return string.sub(orignalName, 1, lastMatch - 1), string.sub(orignalName, lastMatch + 1)
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

function FileMgr:DelFile(filePath)
	local cmd = [[del/f/s/q "]]..filePath..[["]]
	print(cmd)
	local fh = io.popen(cmd)
end

function FileMgr:CreateFolder(filePath)
	local cmd = [[mkdir "]]..filePath..[["]]
	-- print(cmd)
	local fh = io.popen(cmd)
	-- 必须保留这里的迭代,不然可能没等这个命令执行完,逻辑就去了其他地方,等着这个命令结果的地方就会坑
	-- 保留迭代的话,会强制逻辑等待这个命令的执行结果再去执行其他逻辑
	for line in fh:lines() do
		-- print(fh)
	end
end

return FileMgr
