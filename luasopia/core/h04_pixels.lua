-- 2021/08/16:created
-- pixel모드는 Gideros의 성능이 더 좋은듯(아마 Gideros는 Pixel객체를 지원하고
-- solar2d는 rectangle shape로 점을 그릴수밖에 없어서 그런듯 하다.)

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

local floor = math.floor
local D2R = math.pi/180
local cos, sin, abs = math.cos, math.sin, math.abs
local tins = table.insert
-- local max = math.max
--local function int(f) return floor(f+0.5) end -- local int = math.floor

-- 직전에 그린 각도와 지정된 각도가 이것보다 커야 새로 그린다
-- 성능 향상과 도트화면 특유의 딱딱 끊어지는 효과를 낼 수 있다
local gapdeg = 5 -- 5:default (3, 5:default,9,15,45)

--------------------------------------------------------------------------------
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
        px.x0, px.y0 = x0, y0
        return px

    end


    function Pixels:__setpx__(px, xf, yf, xsf, ysf)

        px:setPosition(xf, yf)
        px:setScale(xsf, ysf)

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

        local px = newPoly(0, 0, pts)
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

    end

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--2021/08/18:__setrs__()메서드가 한 프레임에 여러 번 호출되는 것을 막기 위해서
-- rot(), scale()함수에는 self.__rsupd 만 true로 만들고 리턴한다
-- 대신 아래 함수를 __iupds에 등록해서 매 프레임마다 체크한다
local function rsupd(self) -- rot and scale update

    if self.__rsupd then
        --print('rsupd')
        self:__setrs__() -- 이 안에서 self.__rsupd=false 로 된다
    end

end


function Pixels:init(sht, seq)

    self.__sht, self.__seq = sht, seq
    self.__bd = newgroup()

    self.__apx, self.__apy = 0.5, 0.5
    
    self.__wdt, self.__hgt = sht.__frmwdt, sht.__frmhgt
    self.__wdt1, self.__hgt1 = sht.__frmwdt-1, sht.__frmhgt-1
    
    -- anchor를 고려했을 때의 원점 좌표
    self.__xoffs = floor(0.5*self.__wdt1 + 0.5)
    self.__yoffs = floor(0.5*self.__hgt1 + 0.5)

    self.__bdrd, self.__bdrr = 0, 0 -- rotationa angle in deg(bdr) and radian(rotr)
    self.__bds, self.__bdxs, self.__bdys = 1, 1, 1
    self.__dxsys = 0
    self.__rdprv = 0 -- 직전에 그린 각도(degree)
    self.__asnr = 0 -- abs(sin(rot))


    self:__setfrm__(1)
    Disp.init(self)

    return self:__addupd__(rsupd)

end



function Pixels:__setfrm__(id)

    self:__rmpxs__() -- 이전에 그려진 모든 점들을 제거한다

    local sht = self.__sht.__txts[id] -- pixel_sheet
    local pxs = {}              -- PiXelS
    -- for k, px in ipairs(pxs) do

    self.__npxs = #sht -- number of pixels
    
    for k=1,self.__npxs do

        local px = sht[k]

        -- 앵커가 반영된 점의 좌표만 저장
        -- wdt1, hgt1을 사용해야 anchor(1,1)로 지정했을 때 정확히 우하점이 된다.
        -- self.__xoffs =  floor(self.__apx*self.__wdt1 + 0.5)
        -- self.__yoffs =  floor(self.__apy*self.__hgt1 + 0.5)
        -- 위 값들은 미리 계산되어 있다.
        local x0 = px.x0 - self.__xoffs
        local y0 = px.y0 - self.__yoffs

        tins(pxs, self:__mkpx__(x0, y0, px.c))

    end

    self.__idfrm = id
    self.__pxs = pxs

    return self:__setrs__()

end


--2021/08/18:부드러운 모양을 위해서 x/y좌표가 정확히 정수가 되는 것은 포기
--단, 원점(anchor point)은 정확히 정수(0,0)의 위치에서 변하지 않는다.
function Pixels:__setrs__()

    local r, xs, ys = self.__bdrr, self.__bdxs, self.__bdys
    --if r==0 and xs==1 and ys==1 then return end

    local xsf, ysf = xs, ys
    
    -- (xscale, yscale)벡터를 r만큼 회전시킨 후 그것의 x,y성분을 뽑아낸다 
    if r~=0 then
        
        -- rotxsxy = (self.__bdxs-self.bdys)*abs(sin(r))
        -- xscale과 yscale이 서로 다른 경우도 있으므로
        -- 회전각에 따라서 이를 보정해주는 역할을 한다
        if xs ~= ys then
            local rotxsys = self.__dxsys*self.__asnr
            xsf = self.__bdxs - rotxsys -- 0도:xs -> 90도:ys
            ysf = self.__bdys + rotxsys -- 0도:ys -> 90도:xs
        end
        
        -- sclip =  1 + 0.37*abs(sin(2*rot))
        -- 45도에 가까워질수록 xs,ys를 조금씩 늘려서 점들 사이의 공간을 메운다
        local sclip = self.__sclip
        xsf = xsf*sclip
        ysf = ysf*sclip

    end

    local snr, csr = self.__snr, self.__csr

    for k = 1, self.__npxs do

        local px = self.__pxs[k]
        local xf, yf = px.x0*xs, px.y0*ys

        -- r을 가장 나중에 변경시켜야 한다
        if r~=0 then
            xf, yf = xf*csr-yf*snr, xf*snr+yf*csr --rot(px.x0,px.y0, rotr)
        end

        -- self:__setpx__(px, int(xf), int(yf), ixsr, iysr)
        self:__setpx__(px, xf, yf, xsf, ysf)
        
    end

    self.__rsupd = false
    
    return self

end
--]]

-- function Pixels:setrot(deg)
--2021/08/17:pxmode일 때 setrot() (and rot()) 함수가 아래로 교체된다
function Pixels:__setr__(deg)

    self.__bdrd = deg

    -- 직전에 그린 각도와 지정된 각도의 차이가 gapdeg보다 커야 새로 그린다
    if abs(deg - self.__rdprv) < gapdeg then
        return self
    end

    local r = deg*D2R
    self.__bdrr = r
    self.__rdprv = deg
    self.__sclip = 1 + 0.37*abs(sin(2*r)) -- 0.41421356 --scale interpolation
    self.__snr, self.__csr, self.__asnr = sin(r), cos(r), abs(sin(r))
    
    --return self:__setrs__()

    self.__rsupd = true
    return self

end


function Pixels:__sets__(s)

    self.__bds, self.__bdxs, self.__bdys = s, s, s
    self.__dxsys = 0 --2021/08/18

    --return self:__setrs__()
    self.__rsupd = true
    return self


end


function Pixels:__setxs__(xs)

    self.__bdxs = xs
    self.__bds = (xs+self.__bdys)*0.5 -- scale값 갱신

    self.__dxsys = self.__bdxs - self.__bdys -- 2021/08/18: xscale-yscale

    --return self:__setrs__()
    self.__rsupd = true
    return self


end


function Pixels:__setys__(ys)

    self.__bdys = ys
    self.__bds = (self.__bdxs+ys)*0.5 -- scale값도 갱신한다
    self.__dxsys = self.__bdxs - self.__bdys -- 2021/08/18: xscale-yscale
    
    --return self:__setrs__()
    self.__rsupd = true
    return self


end


-- 호출 빈도가 낮을 것으로 예상(최초 한 번 정도)
function Pixels:setanchor(ax, ay)

    self.__apx, self.__apy = ax, ay

    -- anchor를 고려했을 때의 원점 좌표
    self.__xoffs = floor(ax*self.__wdt1 + 0.5)
    self.__yoffs = floor(ay*self.__hgt1 + 0.5)

    return self:__setfrm__(self.__idfrm)

end


function Pixels:remove()

    self:__rmpxs__()
    return Disp.remove(self)
    
end



--------------------------------------------------------------------------------
-- 2021/08/18:added for animation
--------------------------------------------------------------------------------


local function timerfunc(self)

    self.__idfrm = self.__idfrm + 1

    if self.__idfrm > self.__maxidfrm then

        self.__idfrm = 1
        self.__loopcnt = self.__loopcnt + 1

        if self.__loopcnt == self.__loops then
            return self.__tmrsprt:remove()
        end

    end

    return self:__setfrm__(self.__frms[self.__idfrm])

end

Pixels.play = Sprite.play
Pixels.pause = Sprite.pause
Pixels.resume = Sprite.resume
Pixels.stop = Sprite.stop
Pixels.setframe = Sprite.setframe


Pixels.anchor = Pixels.setanchor