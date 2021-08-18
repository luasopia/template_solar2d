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
local function int(f) return floor(f+0.5) end -- local int = math.floor
local D2R = math.pi/180
local cos, sin = math.cos, math.sin
local abs, max = math.abs, math.max
local tins = table.insert

-- 직전에 그린 각도와 지정된 각도가 이것보다 커야 새로 그린다
-- (성능향상을 위해서)
local gapdeg = 5 -- 5:default (3,5,9,15,45)

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
        if xsf>1 then px:setScaleX(xsf) end
        if ysf>1 then px:setScaleY(ysf) end

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
        if xsf>1 then px.xScale = xsf end
        if ysf>1 then px.yScale = ysf end

    end

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function Pixels:init(shts, seq)

    self.__bd = newgroup()
    self.__apx, self.__apy = 0.5, 0.5

    self.__shts = shts

    self.__wdt, self.__hgt = shts.__wdt, shts.__hgt
    self.__wdt1, self.__hgt1 = shts.__wdt-1, shts.__hgt-1

    self.__bdrd, self.__bdrr = 0, 0 -- rotationa angle in deg(bdr) and radian(rotr)
    self.__bds, self.__bdxs, self.__bdys = 1, 1, 1
    self.__rdprv = 0 -- 직전에 그린 각도(degree)


    self:setframe(1)
    return Disp.init(self)

end



function Pixels:setframe(id)

    self:__rmpxs__() -- 이전에 그려진 모든 점들을 제거한다

    local sht = self.__shts[id] -- pixel_sheet
    local pxs = {}              -- PiXelS
    -- for k, px in ipairs(pxs) do

    self.__npxs = #sht -- number of pixels
    
    for k=1,self.__npxs do

        local px = sht[k]

        -- 앵커가 반영된 점의 좌표만 저장
        -- wdt1, hgt1을 사용해야 anchor(1,1)로 지정했을 때 정확히 우하점이 된다.
        -- local x0 = px.x0 - int(self.__apx*self.__wdt1)
        -- local y0 = px.y0 - int(self.__apy*self.__hgt1)
        local x0 = px.x0 - floor(self.__apx*self.__wdt1 + 0.5)
        local y0 = px.y0 - floor(self.__apy*self.__hgt1 + 0.5)

        tins(pxs, self:__mkpx__(x0, y0, px.c))

    end

    self.__idfrm = id
    self.__pxs = pxs

    return self:__setrs__()

end


-- --[[
function Pixels:__setrs__()


    local r, xs, ys = self.__bdrr, self.__bdxs, self.__bdys
    local ixsr, iysr = floor(xs+0.5), floor(ys+0.5) -- +0.95

    -- (xscale, yscale)벡터를 r만큼 회전시킨 후 그것의 x,y성분을 뽑아낸다 
    if r~=0 then
        -- ixsr = max(ixsr, int( abs(xs*cos(r)-ys*sin(r)) )) -- +0.95
        -- iysr = max(iysr, int( abs(xs*sin(r)+ys*cos(r)) )) -- +0.95
        
        -- int()를 floor(x+0.5)로 치환하여 약간 더 빠르게
        -- ixsr = max(ixsr, floor( abs(xs*cos(r)-ys*sin(r)) +0.5 )) -- +0.58578
        -- iysr = max(iysr, floor( abs(xs*sin(r)+ys*cos(r)) +0.5 )) -- 

        ixsr = max(ixsr, floor( abs(xs*cos(r)-ys*sin(r)) +0.5 ))
        iysr = max(iysr, floor( abs(xs*sin(r)+ys*cos(r)) +0.5 ))

    end

    for k = 1, self.__npxs do

        local px = self.__pxs[k]
        local xf, yf = px.x0*xs, px.y0*ys

        -- r을 가장 나중에 변경시켜야 한다
        if r~=0 then
            xf, yf = xf*cos(r)-yf*sin(r), xf*sin(r)+yf*cos(r) --rot(px.x0,px.y0, rotr)
        end

        -- self:__setpx__(px, int(xf), int(yf), ixsr, iysr)
        self:__setpx__(px, floor(xf+0.5), floor(yf+0.5), ixsr, iysr)
        
    end
    
    return self

end
--]]

-- function Pixels:setrot(deg)
--2021/08/17:pxmode일 때 setrot() (and rot()) 함수가 아래로 교체된다
function Pixels:__setr__(deg)

    self.__bdrd, self.__bdrr = deg, deg*D2R
    if abs(deg - self.__rdprv) < gapdeg then return end

    self.__rdprv = deg
    
    return self:__setrs__()

end


function Pixels:__sets__(s)

    self.__bds, self.__bdxs, self.__bdys = s, s, s
    return self:__setrs__()

end


function Pixels:__setxs__(xs)

    self.__bdxs = xs
    self.__bds = (xs+self.__bdys)*0.5 -- scale값 갱신
    return self:__setrs__()

end


function Pixels:__setys__(ys)

    self.__bdys = ys
    self.__bds = (self.__bdxs+ys)*0.5 -- scale값도 갱신한다
    return self:__setrs__()

end


function Pixels:setanchor(ax, ay)

    self.__apx, self.__apy = ax, ay
    return self:setframe(self.__idfrm)

end


function Pixels:remove()

    self:__rmpxs__()
    return Disp.remove(self)
    
end


Pixels.anchor = Pixels.setanchor