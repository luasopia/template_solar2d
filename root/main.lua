puts('hello luasopia(v1.0.20)')
local c=0
Timer(100,function()
    putsf("%d",c)
    c=c+1
end,INF)

return require 'ex.test.boomlib'