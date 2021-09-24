-- 2020/07/01 refactoring Circle class 
--------------------------------------------------------------------------------
Circle = class(Shape)
--------------------------------------------------------------------------------
local tins = table.insert
local cos, sin, _2PI, floor = math.cos, math.sin, 2*math.pi, math.floor
--------------------------------------------------------------------------------
function Circle:__mkpts__()

    local r = self.__rds

    -- 2020/07/02 점갯수를 구하는 더 간단한 알고리듬 
    local m = floor(r/12.5)
    local np = 12+(m-m%4) -- 4의 배수로 만든다

    -- (원 둘레) 점들의 좌표를 계산한다.
    local rgap = _2PI/np
    local pts = {0, -r}
    for k=1, np-1 do
        local rot = k*rgap
        local xr, yr = sin(rot)*r, -cos(rot)*r
        tins(pts, xr) -- x
        tins(pts, yr) -- y
    end

    self.__sctx, self.__scty = 0, 0
    self.__hwdt, self.__hhgt = r, r

    return pts

end

--------------------------------------------------------------------------------

function Circle:init(r, opt)

    self.__rds = r

    -- 충돌감지정보
    self.__ccc = {r=r, x=0, y=0, r2=r*r, r0=r}

    self.__orct={-r,-r,  r,-r,  r,r,  -r,r}

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