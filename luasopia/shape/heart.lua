-- 2020/08/19 refactoring Heart class
--------------------------------------------------------------------------------
Heart = class(Shape)
--------------------------------------------------------------------------------
local tblin = table.insert
local cos, sin = math.cos, math.sin
local PI, _2PI =  math.pi, 2*math.pi
local floor = math.floor

-- 2020/07/02 점갯수를 구하는 더 간단한 알고리듬
local function detpts(r)
    -- 원은 12.5로 나누지만 하트는 점의 개수가 더 많아야 해서 8로 나눴다
    local m = floor(r/8) 
    return 12+(m-m%4) -- 4의 배수로 만든다
end

-- heart모양을 그려주는 매개변수방정식
local function eq(t, gain)
    gain = gain or 1
    local x = 16*sin(t)^3
    local y = -12*cos(t)+5*cos(2*t)+2*cos(3*t)+cos(4*t)
    return x*gain, y*gain
end
--------------------------------------------------------------------------------
-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정
local mkpts
if _Gideros then

    mkpts = function(r, ax, ay)
        local gain = r*0.059 --0.06 --외접원의 반지름으로 eq함수의 gain 계산
        local pts = {eq(-PI, gain)}
        local xmin, ymin, xmax, ymax = pts[1], pts[2], pts[1], pts[2]

        local rgap = _2PI / detpts(r) -- 2pi/npts
        for t=-PI+rgap, PI-rgap, rgap do
            local xr, yr = eq(t, gain)
            tblin(pts,xr)
            tblin(pts,yr)

            if xr>xmax then xmax = xr
            elseif xr<xmin then xmin = xr end
            if yr>ymax then ymax = yr
            elseif yr<ymin then ymin = yr end

        end

        -- anchor 위치에 따른 좌표값 보정
        local xof, yof = (xmax-xmin)*(0.5-ax), (ymax-ymin)*(0.5-ay)
        --local xof, yof = 2*r*(0.5-ax), 2*r*(0.5-ay)
        for k=1,#pts-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end
        
        return pts
    end

    -- 2020/06/24 : Corona의 Heart 특성때문에 apx, apy는 0과1사이값으로 조정
    local function setap(ap)
        if ap<0 then return 0
        elseif ap>1 then return 1
        else return ap
        end
    end

    function Heart:anchor(ax, ay)
        self._apx = setap(ax)
        self._apy = setap(ay)
        self:_re_pts1(mkpts(self._rds, self._apx, self._apy))
        return self
    end

elseif _Corona then

    mkpts = function(r, ax, ay)
        local gain = r*0.06 --0.06 --외접원의 반지름으로 eq함수의 gain 계산
        local pts = {eq(-PI, gain)}
        local rgap = _2PI / detpts(r) -- 2pi/npts
        for t=-PI+rgap, PI-rgap, rgap do
            local x, y = eq(t, gain)
            tblin(pts,x)
            tblin(pts,y)
        end

        -- anchor 위치에 따른 좌표값 보정
        local xof, yof = 2*r*(0.5-ax), 2*r*(0.5-ay)
        local np = #pts
        for k=1, #pts-1,2 do
            pts[k] = pts[k] + xof
            pts[k+1] = pts[k+1] + yof
        end

        return pts
    end

    function Heart:anchor(ax, ay)
        self._apx, self._apy = ax, ay
        self:_re_pts1(mkpts(self._rds, ax, ay))
        return self
    end

end

function Heart:init(radius, opt)
    self._rds = radius
    self._apx, self._apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    return Shape.init(self, mkpts(radius, 0.5, 0.5), opt)
end


function Heart:getanchor()
    return self._apx, self._apy
end

--2020/06/23
function Heart:radius(r)
    self._rds = r
    self:_re_pts1( mkpts(r, self._apx, self._apy) )
    return self
end