print('hello luasopia(v1.0.20)')

local blowup = import'blowup'
Timer(100, function()

    local x, y = rand(100,1000), rand(100,200)
    local s = Image('ex/ship.png'):setXY(x,y):setScale(0.7):setDy(rand(3,7))

    Timer(3000, function()
        local x,y = s:getXY()
        s:remove()
        Timer(70,function()
            local b=blowup(rand(5,10)/10)
            -- b:set{x=rand(200,1000),y=rand(200,1700)}--, dx=rand(-10,10), dy=rand(-10,10)}
            b:set{x=x+rand(-30,30),y=y+rand(-30,30)}--, dx=rand(-10,10), dy=rand(-10,10)}
        end,rand(3,6))

    end)

end,INF)