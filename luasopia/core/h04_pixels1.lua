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
        px:setPosition(x0,y0)
        px.x0, px.y0 = x0, y0
        return px

    end

    
    function Pixels:__rmpxs__()
        
        for k = self.__bd:getNumChildren(),1,-1 do
            self.__bd:removeChildAt(k)
        end
        
    end
    
    
    function Pixels:__setpx__(px, xs, ys, d)

        px:setScaleX(xs)
        px:setScaleY(ys)
        px:setRotation(d)

    end


--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
    
    newgroup = _Corona.display.newGroup
    
    local newPoly = _Corona.display.newPolygon
    local pts={0,0, 1,0, 1,1, 0,1} -- PoinTS
    
    
    local newImg = _Corona.display.newImage

    function Pixels:__mkpx__(x0, y0, fc)
        
        local px = newPoly(x0, y0, pts)
        px:setFillColor(fc.r, fc.g, fc.b)
        --local px = newImg('root/ex/pixel.png')
        px.x, px.y = x0,y0
        px.x0, px.y0 = x0, y0

        self.__bd:insert(px)
        return px

    end


    function Pixels:__rmpxs__()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k]:removeSelf()
        end

    end


    function Pixels:__setpx__(px, xs, ys, r)

        px.xScale, px.yScale = xs, ys
        px.rotation = r

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
    self.__prvdeg = 0 -- 직전에 그린 각도(degree)


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

        -- 앵커가 반영된 점의 좌표만 계산. wdt1, hgt1을 사용해야
        -- anchor(1,1)로 지정했을 때 정확히 우하점이 된다.
        local x0 = px.x0 - floor(self.__apx*self.__wdt1 + 0.5)
        local y0 = px.y0 - floor(self.__apy*self.__hgt1 + 0.5)

        tins(pxs, self:__mkpx__(x0, y0, px.c))

    end

    self.__idfrm = id
    self.__pxs = pxs

    return self

end


-- function Pixels:setrot(deg)
--2021/08/17:pxmode일 때 setrot() (and rot()) 함수가 아래로 교체된다
function Pixels:setrot(deg)

    if abs(self.__prvdeg-deg)<5 then
        return Disp.setrot(self,deg)
    end
    
    self.__prvdeg = deg
    local rad = self.__bdrd*D2R
    
    local si = 1 + 0.37*abs(sin(2*rad)) -- 0.41421356
    print(rad, si)
    
    


    for k = 1, self.__npxs do
        
        self:__setpx__(self.__pxs[k], si, si, -deg)
        --self:__setpx__(self.__pxs[k], si, si, 0)
        
    end
    --]]
    
    
    Disp.setrot(self,deg)
    



end


function Pixels:__sets__(s)

    self.__bds, self.__bdxs, self.__bdys = s, s, s
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
Pixels.rot = Pixels.setrot