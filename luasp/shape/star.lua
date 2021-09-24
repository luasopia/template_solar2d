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
function Star:__mkpts__()

    local r, np, irt = self.__rds, self.__npts, self.__irt

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

        if xr>xmax then xmax = xr elseif xr<xmin then xmin = xr end
        if yr>ymax then ymax = yr elseif yr<ymin then ymin = yr end
    end
    
    self.__sctx, self.__scty = (xmax+xmin)*0.5, (ymax+ymin)*0.5
    local hw, hh = (xmax-xmin)*0.5, (ymax-ymin)*0.5
    self.__hwdt, self.__hhgt = hw,hh

    --2021/09/24
    self.__orct={-hw,-hh,  hw,-hh,  hw,hh,  -hw,hh}
    
    return pts
end


--------------------------------------------------------------------------------
function Star:init(radius, opt)

    opt = opt or {}
    self.__rds, self.__npts = radius, opt.points or 5
    self.__irt = opt.ratio or inratio0

    local hitr = radius*(0.5+self.__irt*0.5)
    self.__ccc = {r=hitr, x=0,y=0,r2=hitr*hitr, r0=hitr} -- 2021/05/31 added
    return Shape.init(self, self:__mkpts__(), opt)

end


--2020/06/23
function Star:setradius(r)

    self.__rds = r
    self.__ccc = r*(0.5+self.__irt*0.5) -- 2021/05/31 added
    
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


function Star:setpoints(n)

    self.__npts = n

    self.__pts = self:__mkpts__()
    return self:__redraw__()

end


function Star:setratio(rt)

    self.__irt = rt
    self.__ccc = self.__rds*(0.5+self.__irt*0.5) -- 2021/05/31 added
    
    self.__pts = self:__mkpts__()
    return self:__redraw__()

end

-- 2021/05/31 added
Star.radius = Star.setradius
Star.points = Star.setpoints
Star.ratio = Star.setratio