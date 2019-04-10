-- lua-base64-encode

function SAFE_CALL(func, ...)
    local args = {...}
    local argc = select("#", ...)
    local ErrorHandler = function(...) 
        -- todo
        -- print(...) 
    end
    local returns = { xpcall(function() return func(unpack(args, 1, argc)) end, ErrorHandler) }
    local Errcode = returns[1]
    table.remove(returns, 1)
    if Errcode then
        local count = 0
        for k,v in pairs(returns) do
            if k > count then count = k end
        end
        return unpack(returns, 1, count)
    else
        return
    end
end
