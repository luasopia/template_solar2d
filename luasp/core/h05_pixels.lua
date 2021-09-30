--------------------------------------------------------------------------------
-- 2021/08/16:생성
-- pixel모드는 Gideros의 성능이 더 좋은듯(아마 Gideros는 Pixel객체를 지원하고
-- solar2d는 rectangle shape로 점을 그릴수밖에 없어서 그런듯 하다.)
-- 2021/08/23:회전은 native에 맡기고 x/y방향 확대만 픽셀을 조정한다.
-- 즉 회전은 self을 직접 회전시키고 scale관련 메서드는 오버라이드한다
-- 이것으로 각 픽셀을 회전시키는 비용은 줄어들었다.
--------------------------------------------------------------------------------
--[[
local alien = Pixels{
    -- 0,1 are trasparent and white
    a=Color(),
    b=Color(),
    ...
    maps={
        '01ab:aabb:', --[1]
        '...' --[2]
    }
}
--]]

local Disp = Display
local luasp = _luasopia

local floor, sin, abs = math.floor, math.sin, math.abs
local D2R = math.pi/180
local tins = table.insert

-- 직전에 그린 각도와 지정된 각도가 이것보다 커야 새로 그린다
-- 성능 향상과 도트화면 특유의 딱딱 끊어지는 효과를 낼 수 있다
local gapdeg = 5 -- 5:default (3, 5:default,9,15,45)
--------------------------------------------------------------------------------
local pxmode = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Pixels = class(Disp)


local newgroup

--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------
    newgroup = _Gideros.Sprite.new

    local pixelNew = _Gideros.Pixel.new

    
    --2021/08/16:점의 x/y/scale을 여기서 지정할 필요가 없다.
    --group에 점을 생성해서 집어넣기만 한다.
    --  rot=0, scale=1 인 경우의 앵커가 반영된 xy좌표(x0,y0)정보만 저장한다.
    function Pixels:__mkpx__(x0, y0, fc)
        
        local px = pixelNew(fc.hex,1, 1,1)  -- color(hex), alpha, width, height
        self.__bd:addChild(px)
        px:setPosition(x0,y0)
        px.x0, px.y0 = x0, y0
        return px

    end


    function Pixels:__setpx__(px, xf, yf, xsf, ysf)

        px:setPosition(xf, yf)
        px:setScale(xsf, ysf)
        px:setRotation(self.__bdrd)

    end


    function Pixels:__rmpxs__()

        for k = self.__bd:getNumChildren(),1,-1 do
            self.__bd:removeChildAt(k)
          end
    
    end


    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
    
    newgroup = _Corona.display.newGroup
    
    local newPoly = _Corona.display.newPolygon
    local pts={0,0, 1,0, 1,1, 0,1} -- PoinTS
    
    
    -- local newImg = _Corona.display.newImage

    function Pixels:__mkpx__(x0, y0, fc)
        

        -- local px = newImg('root/ex/pixel.png')
        -- px:setFillColor(fc.r, fc.g, fc.b)

        local px = newPoly(x0, y0, pts)
        px:setFillColor(fc.r, fc.g, fc.b)


        self.__bd:insert(px)
        px.x0, px.y0 = x0, y0

        return px

    end


    function Pixels:__rmpxs__()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k]:removeSelf()
        end

    end


    function Pixels:__setpx__(px, xf, yf, xsf, ysf)

        px.x, px.y = xf, yf
        px.xScale, px.yScale = xsf, ysf   
        px.rotation = -self.__bdrd

    end

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- --[[
--2021/08/18:__setrs__()메서드가 한 프레임에 중복해서 호출되는 것을 막기 위해서
-- rot(), scale()함수에는 self.__rsupd 만 true로 만들고 리턴한다
-- 대신 아래 함수를 __iupds에 등록해서 매 프레임마다 체크한다
local function rsupd(self) -- rot and scale update

    if self.__rsupd then
        --print('rsupd')
        self:__setrs__() -- 이 안에서 self.__rsupd=false 로 된다
        -- return self:__setrs__() 라고 하면 안 된다.
        -- self:__setrs__()가 self를 return하기 때문이다
    end

end
--]]


function Pixels:init(sht, seq)

    self.__sht, self.__seq = sht, seq
    self.__bd = newgroup()

    self.__apx, self.__apy = 0.5, 0.5
    
    
    if pxmode then
        
        self.__bdrr = 0 -- 각도를 라디안으로 변경한 값
        self.__dxsys = 0 -- self.__bdxs - self.__bdys 계산값 저장
        self.__rdprv = 0 -- 직전에 그린 각도(rot degree previous)
        self.__asnr = 0 -- abs(sin(rot))
        
        Disp.init(self)
        self:__setfrm__(1)
        return self:__addupd__(rsupd)
        
    else

        self:__setfrm__(1)
        return Disp.init(self)

    end


end


-- 2021/09/05: frame마다 w/h가 변할 수 있으므로
-- w/h값에 의해서 변경되어야 할 값들을 여기에서 계산한다
function Pixels:__setwh__(w,h,forced)

    -- anchor만 변했을 수도 있으므로 아래는 살리면 안된다
    if self.__wdt == w and self.__hgt == h and not forced then return end

    local w_1, h_1 = w-1, h-1
    local ax, ay = self.__apx, self.__apy

    self.__wdt, self.__hgt = w, h
    self.__wdt1, self.__hgt1 = w_1, h_1
    
    -- (앵커가 반영된) 픽셀아트의 원점<0.0>의 그룹(self) 죄표계에서의 좌표
    self.__x0 = -floor(ax*w_1 + 0.5)
    self.__y0 = -floor(ay*h_1 + 0.5)

    -- (__xc,__yc)는 그룹(self) 죄표계에서 픽셀들의 정중앙점 좌표
    -- __getgxy__()에서 사용된다,
    self.__xc = (0.5-ax)*w_1
    self.__yc = (0.5-ay)*h_1

    --2021/08/20:충돌감지를 위해서 추가
    if self.__cpg then -- self.__ccc나 self.__cpt인 경우는 스킵
        local hw, hh = w*0.5, h*0.5
        local xoffs=0.5
        self.__cpg = {
            -hw+xoffs,-hh+xoffs,
            hw+xoffs,-hh+xoffs,
            hw+xoffs,hh-xoffs,
            -hw+xoffs,hh-xoffs,
        }
    end

end



-- 2021/08/25:pxmode로 전환되었을 때 Pixels에서 취해야 할 동작들
function Pixels.__setpxmode__()

    -- Pixels클래스의 scale 관련 메서드 변경
    -- (pxmode에서는 확대시 점좌표들을 직접 계산해야 한다.)
    pxmode = true

    Pixels.setRot = Pixels.__setr__
    Pixels.setScale = Pixels.__sets__
    Pixels.setScaleX = Pixels.__setxs__
    Pixels.setScaleY = Pixels.__setys__
    Pixels.setScaleXY= Pixels.__setxys__
    
    Pixels.getGlobalXY = Pixels.__getgxypx__
    Pixels.__getgxy__ = Pixels.__getgxypx__

end


function Pixels:__setfrm__(id, forced)

    if self.__idfrm == id and not forced then return self end

    
    self:__rmpxs__() -- 이전에 그려진 모든 점들을 제거한다

    local sht = self.__sht.__txts[id] -- pixel_sheet

    --2021/09/05: 아래에서 변경되어야 할 값들을 계산
    self:__setwh__(sht.width, sht.height, forced) 

    local pxs = {}              -- PiXelS
    self.__npxs = #sht -- number of pixels
    
    for k=1,self.__npxs do

        local px = sht[k]

        -- 앵커가 반영된 점의 좌표만 저장
        -- wdt1, hgt1을 사용해야 anchor(1,1)로 지정했을 때 정확히 우하점이 된다.
        -- self.__x0 =  -floor(self.__apx*self.__wdt1 + 0.5)
        -- self.__y0 =  -floor(self.__apy*self.__hgt1 + 0.5)
        -- 위 값들은 미리 계산되어 있다.
        local x = px.x0 + self.__x0
        local y = px.y0 + self.__y0

        --tins(pxs, self:__mkpx__(x0, y0, px.c))
        pxs[k] = self:__mkpx__(x, y, px.c)

    end

    self.__pxs = pxs
    self.__idfrm = id

    
    if pxmode then

        return self:__setrs__()

    else

        return self

    end

end


--2021/08/18:부드러운 모양을 위해서 x/y좌표가 정확히 정수가 되는 것은 포기
--단, 원점(anchor point)은 정확히 정수(0,0)의 위치에서 변하지 않는다.
function Pixels:__setrs__()

    local r, xs, ys = self.__bdrr, self.__bdxs, self.__bdys
    local xsf, ysf = xs, ys
    
    -- (xscale, yscale)벡터를 r만큼 회전시킨 후 그것의 x,y성분을 뽑아낸다 
    if r~=0 then
        
        -- rotxsxy = (self.__bdxs-self.bdys)*abs(sin(r))
        -- xscale과 yscale이 서로 다른 경우 있으므로 점이 직사각형이 되므로
        -- 그대로 회전하면 문제가 된다. 따라서 이를 보정해주는 역할을 한다
        if xs ~= ys then

            local rotxsys = self.__dxsys*self.__asnr
            xsf = xs - rotxsys -- 0도:xs -> 90도:ys -> 180도:xs
            ysf = ys + rotxsys -- 0도:ys -> 90도:xs -> 180도:ys

        end
        
        -- sclip =  1 + 0.37*abs(sin(2*r))
        -- 45도에 가까워질수록 xs,ys를 조금씩 늘려서 점들 사이의 공간을 메운다
        local sclip = self.__sclip
        xsf, ysf = xsf*sclip, ysf*sclip
        
    end


    for k = 1, self.__npxs do

        local px = self.__pxs[k]
        --(px.x0, px.y0)는 px가 rot=0, scale=1일 때의 좌표이다.
        self:__setpx__(px, px.x0*xs, px.y0*ys, xsf, ysf)
        
    end

    self.__rsupd = false
    
    return self

end
--]]

--2021/08/17:pxmode일 때 setRot() 함수가 아래로 교체된다
-- 항상 __bd의 원점(0,0)이 앵커점이다.
function Pixels:__setr__(deg)

    self.__bdrd = deg -- 그리지않아도 __bdrd는 갱신해야 한다

    -- 직전에 그린 각도와 지정된 각도의 차이가 gapdeg보다 커야 새로 그린다
    if abs(deg - self.__rdprv) < gapdeg then

        return self

    end
    
    local r = deg*D2R
    self.__bdrr = r
    self.__rdprv = deg
    --45도각도로 갈수록 scale값을 더 키워서 점간 빈간격을 메꾼다
    -- self.__sclip = 1 + 0.37*abs(sin(2*r)) -- 0.41421356 --scale interpolation
    self.__sclip = 1 + 0.28*abs(sin(2*r)) -- (inital gain:0.37) --scale interpolation
    self.__asnr = abs(sin(r))
    
    self.__rsupd = true
    
    return Disp.setRot(self, deg)

end


function Pixels:__sets__(s)

    self.__bds, self.__bdxs, self.__bdys = s, s, s
    self.__dxsys = 0 --2021/08/18
    self.__rsupd = true
    return self

end


function Pixels:__setxs__(xs)

    self.__bdxs = xs
    self.__bds = (xs+self.__bdys)*0.5 -- scale값 갱신
    self.__dxsys = xs - self.__bdys -- 2021/08/18: xscale-yscale
    self.__rsupd = true
    return self

end


function Pixels:__setys__(ys)

    self.__bdys = ys
    self.__bds = (self.__bdxs+ys)*0.5 -- scale값도 갱신한다
    self.__dxsys = self.__bdxs - ys -- 2021/08/18: xscale-yscale
    
    --return self:__setrs__()
    self.__rsupd = true
    return self


end


function Pixels:__setxys__(xs, ys)

    self.__bdxs, self.__bdys = xs, ys
    self.__bds = (xs+ys)*0.5 -- scale값도 갱신한다
    self.__dxsys = xs - ys -- 2021/08/18: xscale-yscale
    
    self.__rsupd = true
    return self


end


-- 호출 빈도가 낮을 것으로 예상(최초 한 번 정도)
function Pixels:setAnchor(ax, ay)

    self.__apx, self.__apy = ax, ay

    -- 변경되어야 할 값들은 self:__setwh__()에서
    -- (__setfrm__() 안에서 호출) 계산된다.

    -- 두 번째 인자는 강제로 다시 그리라는 것임
    return self:__setfrm__(self.__idfrm, true)

end


function Pixels:remove()

    self:__rmpxs__()
    return Disp.remove(self)
    
end


-- pxmode에서 pixels객체는 자체적으로 확대를 하기 때문에
-- getGlobalXY()메서드를 아래 함수로 오버라이드해야 한다.
function Pixels:__getgxypx__(x,y)

    -- local xc, yc = (0.5-ax)*w_1, (0.5-ay)*h_1
    -- (xc,yc)는 그룹(self) 죄표계에서 픽셀아트 정중앙점 좌표

    x = ((x or 0)+self.__xc)*self.__bdxs
    y = ((y or 0)+self.__yc)*self.__bdys
    
    return Disp.getGlobalXY(self, x, y)

end


-- pxmode에서 pixels객체는 자체적으로 확대/회전을 하기 때문에
-- pxmode에서 getGlobalXY()메서드를 오버라이드해야 한다.
function Pixels:getGlobalXY(x,y)

    -- local xc, yc = (0.5-ax)*w_1, (0.5-ay)*h_1
    -- (xc,yc)는 그룹(self) 죄표계에서 픽셀들의 정중앙점 좌표

    x = (x or 0)+self.__xc
    y = (y or 0)+self.__yc
    
    return Disp.getGlobalXY(self, x, y)

end

Pixels.__getgxy__ = Pixels.getGlobalXY


--------------------------------------------------------------------------------
-- 2021/08/18:added for animation
--------------------------------------------------------------------------------

-- local timerfunc = luasp.tmrfnsprt
Pixels.play = Sprite.play
Pixels.pause = Sprite.pause
Pixels.resume = Sprite.resume
Pixels.stop = Sprite.stop
Pixels.setFrame = Sprite.setFrame
