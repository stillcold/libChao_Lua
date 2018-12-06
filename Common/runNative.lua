-- call native method from lua

-- Sample code:
-- 
-- local contentTbl = RunNativeCmd("dir")
-- for _,line in pairs (contentTbl or {}) do
-- 	print(line)
-- end

-- This will return a table contains the result,
-- See sample code above for more.

function RunNativeCmd(cmd)
	local fh = io.popen(cmd)
	local contentTbl = {}

	for line in fh:lines() do
		table.insert(contentTbl, line)
	end

	fh:close()
	return contentTbl
end
