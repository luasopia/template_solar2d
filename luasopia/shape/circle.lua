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
function Circle:__mkpts__()

    local r = self.__rds
    local pts, np = rawmkpts(r)

    self.__xmn, self.__xmx = -r, r
    self.__ymn, self.__ymx = -r, r
    return pts
end

--------------------------------------------------------------------------------

function Circle:init(radius, opt)
    self.__rds = radius
    self.__ccc = radius
    
    return Shape.init(self, self:__mkpts__(), opt)
end


--2020/06/23
function Circle:setradius(r)
    self.__rds = r
    self.__ccc = r

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

--2021/05/11
function Circle:getradius()
    return self.__rds
end

Circle.radius = Circle.setradius