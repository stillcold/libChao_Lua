-- call native method from lua

-- Sample code:
-- 
-- local allFiles = RunNativeMethod("dir")
-- for line in allFiles:lines() do
-- 	print(line)
-- end

-- This will return a user data which can be access in lua code by lines method,
-- See sample code above for more.

function RunNativeMethod(cmd)
	return io.popen(cmd)
end
