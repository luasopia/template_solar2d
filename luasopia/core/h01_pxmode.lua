--------------------------------------------------------------------------------
--2021/08/13: pixel모드(저해상도)를 실시간으로 구현하고자 하는 아이디어
--2021/08/14: pixelmode를 추가
--저해상도에서 pixel(이미지내의 점)의 위치가 정확하게 잡히려면 지정된 xy좌표가
--정수가 되어야 한다. 실수가 되면 정확한 위치에 점이 놓이지 않는다.
--------------------------------------------------------------------------------
local int = math.floor


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

    _luasopia.scnlayer:setscale(scale)

    screen.width = int(screen.width0/scale)
    screen.height = int(screen.height0/scale)

    screen.centerx = int(screen.width*0.5)
    screen.centery = int(screen.height*0.5)

    -- 아래는 Display.init() 안에서 사용된다
    _luasopia.centerx = screen.centerx
    _luasopia.centery = screen.centery

    screen.__pxmode = mode
    screen.__pxscale = scale

    -- Pixels클래스의 rot, scale 메서드 변경
    -- pxmode에서는 회전과 확대시 점좌표들을 직접 계산해야 한다.
    Pixels.setrot, Pixels.rot = Pixels.__setr__, Pixels.__setr__
    Pixels.setscale, Pixels.scale = Pixels.__sets__, Pixels.__sets__
    Pixels.setxscale, Pixels.xscale = Pixels.__setxs__, Pixels.__setxs__
    Pixels.setyscale, Pixels.yscale = Pixels.__setys__, Pixels.__setys__
    Pixels.getglobalxy = Pixels.__getgxy__

end
