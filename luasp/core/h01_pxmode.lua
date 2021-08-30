--------------------------------------------------------------------------------
--2021/08/13: pixel모드(저해상도)를 실시간으로 구현하고자 하는 아이디어
--2021/08/14: pixelmode를 추가
--저해상도에서 pixel(이미지내의 점)의 위치가 정확하게 잡히려면 지정된 xy좌표가
--정수가 되어야 한다. 실수가 되면 정확한 위치에 점이 놓이지 않는다.
--------------------------------------------------------------------------------
local int = math.floor
local luasp = _luasopia

--[[
function setpixelmode(mode)

    local scales = {3,4,5,6,8, 10,12,15,20,30, 40,60} --120의 약수(2제외)
    -- mode 1: 360x640 (scale=3)
    -- mode 2: 270x480 (scale=4)
    -- mode 3: 216x384 (scale=5)
    -- mode 4: 180x320 (scale=6) 
    -- mode 5: 135x240 (scale=8) -- default mode
    -- mode 6: 108x192 (scale=10)
    -- mode 7: 90x160 (scale=12)
    -- mode 8: 72x128 (scale=15)
    -- mode 9: 54x96 (scale=20) --
    -- mode 10: 36x64 (scale=30)
    -- mode 11: 27x48 (scale=40)
    -- mode 12: 18x32 (scale=60)

    mode = mode or 5
    local scale = scales[mode]

    luasp.scnlayer:setscale(scale)

    screen.width = int(screen.width0/scale)
    screen.height = int(screen.height0/scale)

    screen.centerx = int(screen.width*0.5)
    screen.centery = int(screen.height*0.5)

    -- 아래는 Display.init() 안에서 사용된다
    luasp.centerx = screen.centerx
    luasp.centery = screen.centery

    -- screen.__pxmode = mode
    -- screen.__pxscale = scale
    luasp.pxmode = mode
    luasp.pxscale = scale


    Pixels.__setpxmode__()

end
--]]

-- pico-8 과 같이 해상도를 128x128로 맞춘다
-- 나머지 영역은 clip
function setpixelmode() -- setpixelmode()

    -- mode 5: 135x240 (scale=8) -- default mode
    local scale = 8
    
    --화면을 좀 위로 올리고 밑에 조이패드를 배치할 까 한다.
    -- local x0, y0 = 3*scale,30*scale --y0=56*scale이 정중앙임
    local x0, y0 = 3*scale,56*scale --y0=56*scale이 정중앙임

    local frame = Rect(130*scale-8,130*scale-8,{strokewidth=3}):setanchor(0,0)
    frame:setxy(x0-2,y0-3):empty()
    luasp.loglayer:add(frame)

    luasp.scnlayer:setscale(scale)


    if _Corona then

        luasp.scnlayer.__bd.x = x0
        luasp.scnlayer.__bd.y = y0
        --- mask layer를 하나 더 둬야 한다

    elseif _Gideros then

        luasp.scnlayer.__bd:setPosition(x0,y0)
        luasp.scnlayer.__bd:setClip(0,0,128,128)

        
    end

    -- luasp.fpsTo30() -- 30fps로 변경하는 것은 포기

    -- screen.width = int(screen.width0/scale)
    -- screen.height = int(screen.height0/scale)

    -- screen.centerx = int(screen.width*0.5)
    -- screen.centery = int(screen.height*0.5)

    screen.width, screen.height = 128, 128
    screen.centerx, screen.centery = 64, 64

    -- 아래는 Display.init() 안에서 사용된다
    luasp.centerx = screen.centerx
    luasp.centery = screen.centery

    -- screen.__pxmode = mode
    -- screen.__pxscale = scale
    luasp.pxmode = true
    luasp.pxscale = scale


    -- puts('(content) width & height: %d x %d', screen.width, screen.height)

    -- 아래 스태틱함수를 실행하면 Pixels객체의 확대/회전에 pixel효과를 준다.
    --단, 퍼포먼스가 많이 떨어진다.(solar2d의 성능이 더 안좋아짐)
    -- Pixels.__setpxmode__()

end

