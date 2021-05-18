-- 2020/07/01 refactoring Circle class 
--------------------------------------------------------------------------------
Circle = class(Shape)
--------------------------------------------------------------------------------
local tblin = table.insert
local cos, sin, _2PI, floor = math.cos, math.sin, 2*math.pi, math.floor
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
--local function rot(x,y,r)
--    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
--end
--------------------------------------------------------------------------------
local function rawmkpts(r)

    -- 점의 갯수(4의 배수로)를 결정한다.
    -- (4배수로 해야 anchor point를 gid/solar 둘 다 동일하게 잡을 수 있다)
    --[[
    local np
    if r<=30 then np = 12
    elseif r<=100 then np = 16
    elseif r<=300 then np = 24
    else
        local m = floor(r/12.5)
        np = m+(4-m%4) -- 4의 배수로 만든다
    end
    --]]

    -- 2020/07/02 점갯수를 구하는 더 간단한 알고리듬 
    local m = floor(r/12.5)
    local np = 12+(m-m%4) -- 4의 배수로 만든다

    -- (원 둘레) 점들의 좌표를 계산한다.
    local rgap = _2PI/np
    local pts = {0, -r}
    for k=1, np-1 do
        local rot = k*rgap
        local xr, yr = sin(rot)*r, -cos(rot)*r
        tblin(pts, xr) -- x
        tblin(pts, yr) -- y
    end

    return pts, np
end

--------------------------------------------------------------------------------

local mkpts

if _Gideros then

    mkpts = function(r, ax, ay)

        local pts, np = rawmkpts(r)

        -- anchor 위치에 따른 좌표값 보정
        -- local xof, yof = (xmax-xmin)*(0.5-ax), (ymax-ymin)*(0.5-ay)
        local xof, yof = 2*r*(0.5-ax), 2*r*(0.5-ay)
        for k=1,2*np-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end
        
        return pts
    end

    -- 2020/06/24 : Corona의 Circle 특성때문에 apx, apy는 0과1사이값으로 조정
    local function setap(ap)
        if ap<0 then
            return 0
        elseif ap>1 then
            return 1
        else
            return ap
        end
    end

    function Circle:anchor(ax, ay)
        self._apx = setap(ax)
        self._apy = setap(ay)
        self:_re_pts1(mkpts(self.__r__, self._npts, self._apx, self._apy))
        return self
    end

elseif _Corona then

    mkpts = function(r, ax, ay)

        local pts, np = rawmkpts(r)

        -- anchor 위치에 따른 좌표값 보정
        local xof, yof = 2*r*(0.5-ax), 2*r*(0.5-ay)
        for k=1,2*np-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end
        
        return pts
    end

    function Circle:anchor(ax, ay)
        self._apx, self._apy = ax, ay
        self:_re_pts1(mkpts(self.__r__, self._npts, self._apx, self._apy))
        return self
    end

end

--------------------------------------------------------------------------------

function Circle:init(radius, opt)
    self.__r__ = radius
    self._apx, self._apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    self.__ccc__ = radius
    return Shape.init(self, mkpts(radius, 0.5, 0.5), opt)
end


function Circle:getanchor()
    return self._apx, self._apy
end

--2020/06/23
function Circle:setradius(r)
    self.__r__ = r
    self.__ccc__ = r
    self:_re_pts1( mkpts(r, self._apx, self._apy) )
    return self
end

--2021/05/11
function Circle:getradius()
    return self.__r__
end

Circle.radius = Circle.setradius