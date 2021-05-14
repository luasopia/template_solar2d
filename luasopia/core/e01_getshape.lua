--------------------------------------------------------------------------------
-- 2020/06/15 started
-- 2020/06/23 refactoring
--[[----------------------------------------------------------------------------
점들 (x1,y1)-(x2,y2)- ... -(xn,yn)-(x1,y1) 을 연결한 폐곡면을 그린다.
(주의) 아래 pts에서는 x1,y1 부터 ** xn,yn 까지만 ** 주어야 한다.
pts = {x1,y1, x2,y2, ..., xn,yn } 
opt = {
    sw -- (required) strokewidth
    sc -- (required) strokecolor
    fc -- (required) fillcolor
}
The anchor point is located at the origin (0,0) point.
------------------------------------------------------------------------------]]
if _Gideros then
--------------------------------------------------------------------------------
    local GShape = _Gideros.Shape

    function _luasopia.getshape(pts, opt)

        local xs, ys = pts[1], pts[2]
        local s = GShape.new()

        s:setLineStyle(opt.sw, opt.sc.hex, opt.sc.a) -- width, color, alpha
        s:setFillStyle(GShape.SOLID, opt.fc.hex, opt.fc.a)
        
        s:beginPath()
        s:moveTo(xs, ys) -- starting at upmost point
        for k=1,#pts,2 do s:lineTo(pts[k], pts[k+1]) end
        s:lineTo(xs, ys) -- ending at the (first) starting point
        s:endPath()
        -- gideros의 shape는 자동으로 원점(0,0)이 anchor point가 된다
        --s:setPosition(self.__apx or 0, self.__apy or 0)
        ------------------------------------------------------------------------
        return s
    end

--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    local newPoly = _Corona.display.newPolygon
    
    -- function Shp:init(pts, opt)
    function _luasopia.getshape(pts, opt)

        local x, y = pts[1], pts[2]
        local xmin,ymin,  xmax,ymax = x,y,  x,y
        for k=3,#pts,2 do
            x, y = pts[k], pts[k+1]
            if x<xmin then xmin = x elseif x>xmax then xmax = x end
            if y<ymin then ymin = y elseif y>ymax then ymax = y end
        end
        
        local s = newPoly(0, 0, pts)
        -- solar2d의 폴리곤은 자동으로 중심점에 anchor가 위치한다.
        -- 그래서 아래와 같이 anchor point를 원점(0,0)으로 만든다.
        s.anchorX = -xmin/(xmax-xmin) --(0-xmin)/(xmax-xmin)
        s.anchorY = -ymin/(ymax-ymin) --(0-ymin)/(ymax-ymin)
        
        local sc = opt.sc
        local fc = opt.fc
        s.strokeWidth = opt.sw
        s:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        s:setFillColor(fc.r, fc.g, fc.b, fc.a)
        ------------------------------------------------------------------------
        return s
    end

end -- elseif _Corona then

--------------------------------------------------------------------------------
-- 2020/06/13 Rawshape 클래스는 lib.Tail 클래스에서 사용됨
--------------------------------------------------------------------------------

local getshp = _luasopia.getshape
local Disp = Display

_luasopia.Rawshape = class(Disp)

function _luasopia.Rawshape:init(pts, opt)
    self.__bd = getshp(pts, opt)
    return Disp.init(self)
end