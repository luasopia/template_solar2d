-- 2020/06/23 refactoring Polygon class 
local tbins = table.insert
local cos, sin, _2PI, sqrt = math.cos, math.sin, 2*math.pi, math.sqrt
--------------------------------------------------------------------------------
Polygon = class(Shape)
--------------------------------------------------------------------------------
-- (x,y)점을 원점간격으로 r(radian)만큼회전시킨 좌표(xr, yr) 반환
--local function rot(x,y,r)
--    return cos(r)*x-sin(r)*y, sin(r)*x+cos(r)*y
--end 
--------------------------------------------------------------------------------
-- 2020/02/23 : anchor위치에 따라 네 꼭지점의 좌표를 결정

function Polygon:__mkpts__()

    local r, np = self.__rds, self.__npts

    local rgap = _2PI/np
    local pts = {0, -r}

    -- local xmin,ymin, xmax, ymax = 0,-r, 0,-r
    
    -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
    local _1_len = 1/(r*sqrt(2*(1-cos(rgap)))) -- 1/(변의 길이)
    local cpg = {0,-r,_1_len}

    for k=1, np-1 do
        local rot = k*rgap
        local xr, yr = sin(rot)*r, -cos(rot)*r
        tbins(pts, xr) -- x
        tbins(pts, yr) -- y

        -- if xr>xmax then xmax = xr
        -- elseif xr<xmin then xmin = xr end
        -- if yr>ymax then ymax = yr
        -- elseif yr<ymin then ymin = yr end


        -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
        tbins(cpg, xr)
        tbins(cpg, yr)
        tbins(cpg, _1_len) -- 세 번째 요소로 1/(변의길이) 값이 저장되어야 한다
    end
    
    self.__cpg = cpg -- 2021/05/20: 충돌판정을 위한 벡터정보 생성

    return pts

end


function Polygon:init(radius, points, opt)

    self.__rds, self.__npts = radius, points
    return Shape.init(self, self:__mkpts__(), opt)

end


--2020/06/23
function Polygon:setradius(r)

    self.__rds = r

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

function Polygon:setpoints(n)
    self.__npts = n
    
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

--2021/05/20
Polygon.radius = Polygon.setradius
Polygon.points = Polygon.setpoints