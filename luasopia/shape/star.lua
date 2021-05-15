-- 2020/07/02 refactoring Star class 
--------------------------------------------------------------------------------
Star = class(Shape)
--------------------------------------------------------------------------------
local tblin = table.insert
local cos, sin, PI, _2PI = math.cos, math.sin, math.pi, 2*math.pi
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
--local function rot(x,y,r)
--    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
--end
local inratio0 = 0.5 -- 0.4= (inner circle radius)/(outer circle radius)
--------------------------------------------------------------------------------
local mkpts
if _Gideros then

    mkpts = function(r, np, irt, ax, ay)
        local rgap = PI/np
        local pts = {0, -r}

        local xmin,ymin, xmax, ymax = 0,-r, 0,-r

        local rot, xr, yr
        for k=1, np*2-1 do
            rot = k*rgap
            if k%2 == 1 then
                xr, yr = sin(rot)*(r*irt), -cos(rot)*(r*irt)
                tblin(pts, xr) -- x
                tblin(pts, yr) -- y
            else
                xr, yr = sin(rot)*r, -cos(rot)*r
                tblin(pts, xr) -- x
                tblin(pts, yr) -- y
            end

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

    -- 2020/06/24 : Corona의 Star 특성때문에 apx, apy는 0과1사이값으로 조정
    local function setap(ap)
        if ap<0 then
            return 0
        elseif ap>1 then
            return 1
        else
            return ap
        end
    end

    function Star:anchor(ax, ay)
        self._apx = setap(ax)
        self._apy = setap(ay)
        local pts = mkpts(self._rds, self._npts, self._irt, self._apx, self._apy)
        self:_re_pts1(pts)
        return self
    end

elseif _Corona then

    mkpts = function(r, np, irt, ax, ay)

        local rgap, rirt = PI/np, r*irt
        local pts = {0, -r}

        local rot, xr, yr
        for k=1, np*2-1 do
            rot = k*rgap
            if k%2 == 1 then
                xr, yr = sin(rot)*rirt, -cos(rot)*rirt
                tblin(pts, xr) -- x
                tblin(pts, yr) -- y
            else
                xr, yr = sin(rot)*r, -cos(rot)*r
                tblin(pts, xr) -- x
                tblin(pts, yr) -- y
            end
        end
        -- --[[
        -- anchor 위치에 따른 좌표값 보정
        local xof, yof = 2*r*(0.5-ax), 2*r*(0.5-ay)
        for k=1,2*np-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end
        --]]
        return pts
    end

    function Star:anchor(ax, ay)
        self._apx, self._apy = ax, ay
        local pts = mkpts(self._rds, self._npts, self._irt, self._apx, self._apy)
        self:_re_pts1(pts)
        return self
    end

end

--------------------------------------------------------------------------------
function Star:init(radius, opt)
    opt = opt or {}
    self._rds, self._npts = radius, opt.points or 5
    self._irt = opt.ratio or inratio0
    self._apx, self._apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, mkpts(radius, self._npts, self._irt, 0.5, 0.5), opt)
end


function Star:getanchor()
    return self._apx, self._apy
end

--2020/06/23
function Star:radius(r)
    self._rds = r
    self:_re_pts1( mkpts(r, self._npts, self._irt, self._apx, self._apy) )
    return self
end

function Star:points(n)
    self._npts = n
    self:_re_pts1( mkpts(self._rds, n, self._irt, self._apx, self._apy) )
    return self
end

function Star:ratio(rt)
    self._irt = rt
    self:_re_pts1( mkpts(self._rds, self._npts, rt, self._apx, self._apy) )
    return self
end
