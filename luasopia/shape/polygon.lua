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

if _Gideros then

    -- mkpts = function(r, np, ax, ay)
    function Polygon:__mkpts__()
        local r, np, ax, ay = self.__rds, self.__npts, self.__apx, self.__apy

        local rgap = _2PI/np
        local pts = {0, -r}

        local xmin,ymin, xmax, ymax = 0,-r, 0,-r
        
        for k=1, np-1 do
            local rot = k*rgap
            local xr, yr = sin(rot)*r, -cos(rot)*r
            tbins(pts, xr) -- x
            tbins(pts, yr) -- y

            if xr>xmax then xmax = xr
            elseif xr<xmin then xmin = xr end
            if yr>ymax then ymax = yr
            elseif yr<ymin then ymin = yr end
        end
        

        -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
        local _1_len = 1/(r*sqrt(2*(1-cos(_2PI/np)))) -- 1/(변의 길이)
        local cpg = {}
        
        -- anchor 위치에 따른 좌표값 보정
        local xoff, yoff = (xmax-xmin)*(0.5-ax), (ymax-ymin)*(0.5-ay)
        -- local xof, yof = (xmax-xmin)*(0.5-ax), ymin+(ymax-ymin)*ay
        for k=1,2*np-1,2 do
            pts[k] = pts[k] + xoff
            pts[k+1] = pts[k+1] + yoff

            -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
            tbins(cpg, pts[k])
            tbins(cpg, pts[k+1])
            tbins(cpg, _1_len) -- 세 번째 요소로 1/(변의길이) 값이 저장되어야 한다
        end
        
        self.__cpg = cpg -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
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

    function Polygon:setanchor(ax, ay)
        self.__apx = setap(ax)
        self.__apy = setap(ay)
        self:_re_pts1(self:__mkpts__())
        return self
    end

elseif _Corona then

    --mkpts = function(r, np, ax, ay)
    function Polygon:__mkpts__()
        local r, np, ax, ay = self.__rds, self.__npts, self.__apx, self.__apy

        local rgap = _2PI/np
        local pts = {0, -r}

        for k=1, np-1 do
            local rot = k*rgap
            tbins(pts, sin(rot)*r) -- x
            tbins(pts, -cos(rot)*r) -- y
        end
        
        -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
        local _1_len = 1/(r*sqrt(2*(1-cos(_2PI/np)))) -- 1/(변의 길이)
        local cpg = {}
        
        
        -- anchor 위치에 따른 좌표값 보정
        local xoff, yoff = 2*r*(0.5-ax), 2*r*(0.5-ay)
        for k=1, 2*np-1, 2 do
            pts[k] = pts[k] + xoff
            pts[k+1] = pts[k+1] + yoff
            
            -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
            tbins(cpg, pts[k])
            tbins(cpg, pts[k+1])
            tbins(cpg, _1_len) -- 세 번째 요소로 1/(변의길이) 값이 저장되어야 한다
        end
        
        self.__cpg = cpg -- 2021/05/20: 충돌판정을 위한 벡터정보 생성
        return pts
    end

    function Polygon:setanchor(ax, ay)
        self.__apx, self.__apy = ax, ay
        self:_re_pts1(self:__mkpts__())
        return self
    end

end

function Polygon:init(radius, points, opt)
    self.__rds, self.__npts = radius, points
    self.__apx, self.__apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    
    return Shape.init(self, self:__mkpts__(), opt)
end


function Polygon:getanchor()
    return self.__apx, self.__apy
end

--2020/06/23
function Polygon:setradius(r)
    self.__rds = r
    self:_re_pts1( self:__mkpts__() )
    return self
end

function Polygon:setpoints(n)
    self.__npts = n
    self:_re_pts1( self:__mkpts__() )
    return self
end

--2021/05/20
Polygon.radius = Polygon.setradius
Polygon.points = Polygon.setpoints

Polygon.anchor = Polygon.setanchor
