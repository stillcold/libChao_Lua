

local simpleLuaSocket = require "SimpleLuaSocket"

local socket = simpleLuaSocket:SocketConnect("10.240.160.221", 6001)

simpleLuaSocket:SocketSend(socket, "lua\r\n")

print(simpleLuaSocket:SocketRecieve(socket))

simpleLuaSocket:SocketSend(socket, [==[print("hi")]==].."\r\n")

print(simpleLuaSocket:SocketRecieve(socket))

simpleLuaSocket:SocketClose(socket)
