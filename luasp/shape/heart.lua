-- 2020/08/19 refactoring Heart class
--------------------------------------------------------------------------------
local tins = table.insert
local cos, sin = math.cos, math.sin
local PI, _2PI =  math.pi, 2*math.pi
local floor = math.floor
local Shape = _luasopia.Shape
--------------------------------------------------------------------------------
Heart = class(Shape)
--------------------------------------------------------------------------------

-- 2020/07/02 점갯수를 구하는 더 간단한 알고리듬
local function detpts(r)
    -- 원은 12.5로 나누지만 하트는 점의 개수가 더 많아야 해서 8로 나눴다
    --local m = floor(r/8) 
    local m = floor(r/5) -- 2021/05/31 해상도를 더 높였다
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
function Heart:__mkpts__()

    local gain = self.__rds*0.059 --0.06 --외접원의 반지름으로 eq함수의 gain 계산
    local pts = {eq(-PI, gain)}
    local xmin, ymin, xmax, ymax = pts[1], pts[2], pts[1], pts[2]

    local rgap = _2PI / detpts(self.__rds) -- 2pi/npts
    for t = -PI+rgap, PI-rgap, rgap do
        local xr, yr = eq(t, gain)
        tins(pts,xr)
        tins(pts,yr)

        if xr>xmax then xmax = xr
        elseif xr<xmin then xmin = xr end
        if yr>ymax then ymax = yr
        elseif yr<ymin then ymin = yr end

    end

    self.__sctx, self.__scty = (xmax+xmin)*0.5, (ymax+ymin)*0.5
    local hw, hh = (xmax-xmin)*0.5, (ymax-ymin)*0.5
    self.__hwdt, self.__hhgt = hw,hh

    --2021/09/24
    self.__orct={-hw,-hh,  hw,-hh,  hw,hh,  -hw,hh}

    return pts

end


function Heart:init(r, opt)

    self.__rds = r
    local hitr = r*0.85
    self.__ccc = {r=hitr, x=0,y=0,r2=hitr*hitr, r0=hitr}
    return Shape.init(self, self:__mkpts__(), opt)
    
end

--2020/06/23
function Heart:setRadius(r)

    self.__rds = r
    self.__ccc = r*0.85
    
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end
