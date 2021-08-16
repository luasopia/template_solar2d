-- 2021/08/16:created
-- pixel모드는 Gideros의 성능이 더 좋은듯(아마 Gideros는 Pixel객체를 지원하고
-- solar2d는 rectangle shape로 점을 그릴수밖에 없어서 그런듯 하다.)

-- setscale(s)은 xscale, yscale 모두 s로 설정한다.
-- setxscale(xs) 나 setyscale(ys)은 scale값도 (xs+ys)/2값으로 갱신한다.
-- getscale()은 (xs+ys)/2값을 반환한다

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

--[[
local p='0110:1001:0110'
for k =1, #p do
    print(type(p:sub(k,k)))
end
--]]
local Disp = Display

local floor = math.floor
local function int(f) return floor(f+0.5) end -- local int = math.floor
local D2R = math.pi/180

local cos, sin = math.cos, math.sin
--local function rot(x,y,r)
--    return  int(x*cos(r)-y*sin(r)), int(x*sin(r)+y*cos(r))
--end
local abs = math.abs
local tins = table.insert


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
        if xsf then px:setScaleX(xsf) end
        if ysf then px:setScaleY(ysf) end

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


    function Pixels:__mkpx__(x0, y0, fc)
            
        local px = newPoly(0, 0, pts)
        self.__bd:insert(px)
        px:setFillColor(fc.r, fc.g, fc.b)
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
        if xsf then px.xScale = xsf end
        if ysf then px.yScale = ysf end

    end


--[[
    function Pixels:__setrs__()

        -- print('__setrs__')

        local r, xs, ys = self.__bdrr, self.__bdxs, self.__bdys
        local ixs, iys, ixsr, iysr
        -- floor(s+n)에서 n~[0.5,1)값에 따라서 확대할 때 줄이 생길수도 있다.
        -- 소수점 확대시(예로 1.2) 점들간 간격이 없어지는 값이 0.95이다
        if xs~=1 then
            ixs = floor(xs+0.95)
        end
        
        if ys~=1 then
            iys = floor(ys+0.95)
        end

        -- 2021/08/16:r~=0이 아니고 scale~=1
        if r~=0 then
            -- ixsr = floor( abs(xs*cos(r)-ys*sin(r)) + 1.01 )
            -- iysr = floor( abs(xs*sin(r)+ys*cos(r)) + 1.01 )

            -- ixsr = floor( abs(xs*cos(r)-ys*sin(r))  + 1)
            -- iysr = floor( abs(xs*sin(r)+ys*cos(r))  + 1)
            
            -- 이게 확대했을 때 (특히 90n 각도일 때) 제일 보기 좋다
            ixsr = floor( abs(xs*cos(r)-ys*sin(r))  + 0.95) -- 0.95
            if ixsr < xs then ixsr=xs end
            iysr = floor( abs(xs*sin(r)+ys*cos(r))  + 0.95)
            if iysr < ys then iysr=ys end

        end
    
        for k = self.__bd.numChildren, 1, -1 do

            local px = self.__bd[k]
            local x, y = px.x0, px.y0

            if xs ~=1 then
                x = int(x*xs)
                px.xScale = ixs    
            end

            if ys ~=1 then
                y = int(y*ys)
                px.yScale = iys    
            end

            -- r을 가장 나중에 변경시켜야 한다
            if r~=0 then
                x, y = int(x*cos(r)-y*sin(r)), int(x*sin(r)+y*cos(r)) --rot(px.x0,px.y0, rotr)
                px.xScale, px.yScale = ixsr, iysr            
            end


            px.x, px.y = x, y

        end
        
        return self
    
    end
--]]
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
        local x0 = px.x0 - int(self.__apx*self.__wdt1)
        local y0 = px.y0 - int(self.__apy*self.__hgt1)

        tins(pxs, self:__mkpx__(x0, y0, px.c))

    end

    self.__idfrm = id
    self.__pxs = pxs

    return self:__setrs__()

end


function Pixels:__setrs__()

    local r, xs, ys = self.__bdrr, self.__bdxs, self.__bdys
    local ixs, iys, ixsr, iysr
    -- floor(s+n)에서 n~[0.5,1)값에 따라서 확대할 때 줄이 생길수도 있다.
    -- 소수점 확대시(예로 1.2) 점들간 간격이 없어지는 값이 0.95이다
    if xs~=1 then
        ixs = floor(xs+0.95)
    end
    
    if ys~=1 then
        iys = floor(ys+0.95)
    end

    if r~=0 then
        -- ixsr = floor( abs(xs*cos(r)-ys*sin(r)) + 1.01 )
        -- iysr = floor( abs(xs*sin(r)+ys*cos(r)) + 1.01 )

        -- ixsr = floor( abs(xs*cos(r)-ys*sin(r))  + 1)
        -- iysr = floor( abs(xs*sin(r)+ys*cos(r))  + 1)
        
        -- 이게 확대했을 때 (특히 90n 각도일 때) 제일 보기 좋다
        ixsr = floor( abs(xs*cos(r)-ys*sin(r))  + 0.95) -- 0.95
        if ixsr < xs then ixsr=xs end
        iysr = floor( abs(xs*sin(r)+ys*cos(r))  + 0.95)
        if iysr < ys then iysr=ys end

    end

    for k = 1, self.__npxs do

        local px = self.__pxs[k]
        local xf, yf, xsf, ysf = px.x0, px.y0, nil, nil

        if xs ~=1 then
            xf, xsf = int(xf*xs), ixs
        end

        if ys ~=1 then
            yf, ysf = int(yf*ys), iys
        end

        -- r을 가장 나중에 변경시켜야 한다
        if r~=0 then
            xf, yf = int(xf*cos(r)-yf*sin(r)), int(xf*sin(r)+yf*cos(r)) --rot(px.x0,px.y0, rotr)
            xsf, ysf = ixsr, iysr          
        end

        -- px.x, px.y = xf, yf
        -- if xsf then px.xScale = xsf end
        -- if ysf then px.yScale = ysf end
        self:__setpx__(px,xf,yf,xsf,ysf)

    end
    
    return self

end

function Pixels:setrot(deg)

    self.__bdrd, self.__bdrr = deg, deg*D2R
    return self:__setrs__()

end


function Pixels:setscale(s)

    self.__bds, self.__bdxs, self.__bdys = s, s, s
    return self:__setrs__()

end


function Pixels:setxscale(xs)

    self.__bdxs = xs
    self.__bds = (xs+self.__bdys)*0.5 -- scale값 갱신
    return self:__setrs__()

end


function Pixels:setyscale(ys)

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


function Pixels:getrot()

    return self.__bdrd

end


function Pixels:getscale()

    return self.__bds

end


Pixels.anchor = Pixels.setanchor
Pixels.rot = Pixels.setrot
Pixels.scale = Pixels.setscale
Pixels.xscale = Pixels.setxscale
Pixels.yscale = Pixels.setyscale