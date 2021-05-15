-- 2020/06/23 refactoring Polygon class 
--------------------------------------------------------------------------------
Polygon = class(Shape)
--------------------------------------------------------------------------------
local tblin = table.insert
local cos, sin, _2PI = math.cos, math.sin, 2*math.pi
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
--local function rot(x,y,r)
--    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
--end
--------------------------------------------------------------------------------
-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
local mkpts
if _Gideros then

    mkpts = function(r, np, ax, ay)
        local rgap = _2PI/np
        local pts = {0, -r}

        local xmin,ymin, xmax, ymax = 0,-r, 0,-r

        for k=1, np-1 do
            local rot = k*rgap
            local xr, yr = sin(rot)*r, -cos(rot)*r
            tblin(pts, xr) -- x
            tblin(pts, yr) -- y

            if xr>xmax then xmax = xr
            elseif xr<xmin then xmin = xr end
            if yr>ymax then ymax = yr
            elseif yr<ymin then ymin = yr end
        end
        
        -- anchor 위치에 따른 좌표값 보정
        local xof, yof = (xmax-xmin)*(0.5-ax), (ymax-ymin)*(0.5-ay)
        -- local xof, yof = (xmax-xmin)*(0.5-ax), ymin+(ymax-ymin)*ay
        for k=1,2*np-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end
        
        return pts
    end

    -- 2020/06/24 : Corona의 Polygon 특성때문에 apx, apy는 0과1사이값으로 조정
    local function setap(ap)
        if ap<0 then
            return 0
        elseif ap>1 then
            return 1
        else
            return ap
        end
    end

    function Polygon:anchor(ax, ay)
        self._apx = setap(ax)
        self._apy = setap(ay)
        self:_re_pts1(mkpts(self._rds, self._npts, self._apx, self._apy))
        return self
    end

elseif _Corona then

    mkpts = function(r, np, ax, ay)
        local rgap = _2PI/np
        local pts = {0, -r}

        for k=1, np-1 do
            local rot = k*rgap
            tblin(pts, sin(rot)*r) -- x
            tblin(pts, -cos(rot)*r) -- y
        end
        
        -- anchor 위치에 따른 좌표값 보정
        local xof, yof = 2*r*(0.5-ax), 2*r*(0.5-ay)
        for k=1,2*np-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end
        
        return pts
    end

    function Polygon:anchor(ax, ay)
        self._apx, self._apy = ax, ay
        self:_re_pts1(mkpts(self._rds, self._npts, self._apx, self._apy))
        return self
    end

end

function Polygon:init(radius, points, opt)
    self._rds, self._npts = radius, points
    self._apx, self._apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, mkpts(radius, points, 0.5, 0.5), opt)
end


function Polygon:getanchor()
    return self._apx, self._apy
end

--2020/06/23
function Polygon:radius(r)
    self._rds = r
    self:_re_pts1( mkpts(r,self._npts, self._apx, self._apy) )
    return self
end

function Polygon:points(n)
    self._npts = n
    self:_re_pts1( mkpts(self._rds, n, self._apx, self._apy) )
    return self
end
