-- call native method from lua

function RunNativeMethod(cmd)
	return io.popen(cmd)
end
