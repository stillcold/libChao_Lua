-- It can be replaced by lfs

local FileMgr = {}

function FileMgr:GetAllFileNameInDir(dir)
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
		--print("raw", line)
		local time, info, fileName = string.match(line, "(%d%d%d%d/%d%d/%d%d%s+%d%d:%d%d)%s+[^%d^%w]+([%d%w,]+)[^%d^%w]+([%w%d._]+)")
		if time and info and fileName then

			--print("matched", time, info, fileName) 
			if info ~= "DIR" then
				candidateFileName = dir..fileName
				if io.open(candidateFileName, "r") then
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

return FileMgr
