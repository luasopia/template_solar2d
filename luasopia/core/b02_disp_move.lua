-- print('core.disp_tr')

local Dp = Display

function Dp:__playd()
    local d = self.__d
    local t
    --print(self:getAlpha())
    if d.dx then self:x(self:getx() + d.dx) end
    if d.dy then self:y(self:gety() + d.dy) end
    t=d.dr or d.drot ;if t then self:r(self:getr() + t) end
    t=d.ds or d.dscale; if t then self:s(self:gets() + t) end
    t=d.da or d.dalpha; if t then self:a(self:geta() + t) end

    t=d.dxs or d.dxscale; if t then self:xs(self:getxs() + t) end
    t=d.dys or d.dyscale; if t then self:ys(self:getys() + t) end
end

function Dp:move(arg) self.__d = arg; return self end
function Dp:stopmove() self.__d = nil; return self end

--------------------------------------------------------------------------------
-- 2020/02/18, 2021/04/27 : modified as follows
--------------------------------------------------------------------------------
function Dp:setdx(d) self.__d=self.__d or {}; self.__d.dx=d; return self end
function Dp:setdy(d) self.__d=self.__d or {}; self.__d.dy=d; return self end
function Dp:setdrot(d) self.__d=self.__d or {}; self.__d.dr = d; return self end
function Dp:setdscale(d) self.__d = self.__d or {}; self.__d.ds = d; return self end
function Dp:setdalpha(d) self.__d = self.__d or {}; self.__d.da = d; return self end
function Dp:setdxscale(d) self.__d=self.__d or {}; self.__d.dxs = d; return self end
function Dp:setdyscale(d) self.__d=self.__d or {}; self.__d.dys = d; return self end
function Dp:setdxdy(dx,dy) self.__d=self.__d or {}; self.__d.dx,self.__d.dy=dx,dy; return self end

--------------------------------------------------------------------------------
-- 2020/02/25 : add getd() methods
--------------------------------------------------------------------------------
function Dp:getdx() if self.__d==nil then return 0 else return self.__d.dx or 0 end end
function Dp:getdy() if self.__d==nil then return 0 else return self.__d.dy or 0 end end
function Dp:getdrot() if self.__d==nil then return 0 else return self.__d.dr or 0 end end
function Dp:getdscale() if self.__d==nil then return 0 else return self.__d.ds or 0 end end
function Dp:getdalpha() if self.__d==nil then return 0 else return self.__d.da or 0 end end
function Dp:getdxscale() if self.__d==nil then return 0 else return self.__d.dxscale or 0 end end
function Dp:getdyscale() if self.__d==nil then return 0 else return self.__d.dyscale or 0 end end

function Dp:getdxdy()
    if self.__d==nil then return 0, 0
    else return (self.__d.dx or 0), (self.__d.dy or 0) end
end

--------------------------------------------------------------------------------
-- 2021/04/27 : rearranged the methods
--------------------------------------------------------------------------------
Dp.dx = Dp.setdx
Dp.dy = Dp.setdy
Dp.dr = Dp.setdrot 
Dp.ds = Dp.setdscale
Dp.da = Dp.setdalpha
Dp.dxs = Dp.setdxscale
Dp.dys = Dp.setdyscale
Dp.dxdy = Dp.setdxdy

Dp.getdr = Dp.getdrot
Dp.getds = Dp.getdscale
Dp.getda = Dp.getdalpha
Dp.getdxs =  Dp.getdxscale
Dp.getdys = Dp.getdyscale


