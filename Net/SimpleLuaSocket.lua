
--[[
luasocket 的 receive 函数是有坑的,关于它的参数必须说明一下:
- '*a' : 设置这个参数之后，socket被closed之后才会返回，如果设置了阻塞方式，那么在socket关闭之前，这里将一直阻塞着，不会返回任何东西。
- '*l' : 设置这个参数之后，当收到数据中的字符有回车换行时才会返回，且回车换行在返回的数据中会被抹掉，如果收到的数据中没有回车换行，将永远不会返回。
- number : 这个表示缓冲中大于等于number个字符时，函数才返回，不然会一直阻塞。
- 只要上边三种情况导致阻塞，就只能在sokect关闭的情况下才能返回。这时候缓冲中剩余的由于数据也会全部返回，并存放在返回的第三个参数partial中，而返回的第一个参数为nil。解决阻塞的办法就是在调用receive函数之前调用socket:settimeout()函数，设置阻塞的时间。超时过后，receive函数就会返回，这时如果缓冲中有数据，那么会一起返回，在partial中。下面的函数这么写也不是非常严谨

- 可以参考下面的文章看看怎么搭建win版本的luasocket
[blog](https://blog.csdn.net/GiveMeFive_1003/article/details/76209815)
--]]

local SimpleLuaSocket = {}

local socket = require("socket")

function SimpleLuaSocket:SocketConnect(host, port)
	local sock = assert(socket.connect(host, port))
	return sock
end

function SimpleLuaSocket:SocketSend(sock, content)
if not sock then return end
	sock:send(content)
end

-- Sample of checkEndFun function
-- local function checkEndFun(data)
-- 	if #data > 0 then
-- 		return true
-- 	end
-- end

function SimpleLuaSocket:SocketRecieve(sock, checkEndFun)
	local data = ""

	while (1) do
		sock:settimeout(0)

		local chunk, status, partial = sock:receive(1024)

		data = data..partial

		if checkEndFun and type(checkEndFun) == "function" then
			if checkEndFun(data) == true then
				return data
			end
		else
			if #data > 0 then
				return data
			end
		end

		if status == "closed" then
			return data
		end
	end
end

function SimpleLuaSocket:SocketClose(sock)
	if not sock then return end
	sock:close()
end


return SimpleLuaSocket
