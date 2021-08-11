local Dp = Display

function Dp:__playmv__()
    local d = self.__mv
    local t
    --print(self:getAlpha())
    if d.dx then self:x(self:getx() + d.dx) end
    if d.dy then self:y(self:gety() + d.dy) end
    if d.drot then self:rot(self:getrot() +  d.drot) end
    if d.dscale then self:scale(self:getscale() + d.dscale) end
    if d.dalpha then self:alpha(self:getalpha() + d.dalpha) end

    if d.dxscale then self:xscale(self:getxscale() + d.dxscale) end
    if d.dyscale then self:yscale(self:getyscale() + d.dyscale) end
end


function Dp:move(arg)

    self.__mv = arg
    return self

end


function Dp:stopmove()

    self.__mv = nil
    return self
    
end

--------------------------------------------------------------------------------
-- 2020/02/18, 2021/04/27 : modified as follows
--------------------------------------------------------------------------------
function Dp:setdx(d) self.__mv=self.__mv or {}; self.__mv.dx=d; return self end
function Dp:setdy(d) self.__mv=self.__mv or {}; self.__mv.dy=d; return self end
function Dp:setdrot(d) self.__mv=self.__mv or {}; self.__mv.drot = d; return self end
function Dp:setdscale(d) self.__mv = self.__mv or {}; self.__mv.dscale = d; return self end
function Dp:setdalpha(d) self.__mv = self.__mv or {}; self.__mv.dalpha = d; return self end
function Dp:setdxscale(d) self.__mv=self.__mv or {}; self.__mv.dxscale = d; return self end
function Dp:setdyscale(d) self.__mv=self.__mv or {}; self.__mv.dyscale = d; return self end
function Dp:setdxdy(dx,dy) self.__mv=self.__mv or {}; self.__mv.dx,self.__mv.dy=dx,dy; return self end

--------------------------------------------------------------------------------
-- 2020/02/25 : add getd() methods
--------------------------------------------------------------------------------
function Dp:getdx() if self.__mv==nil then return 0 else return self.__mv.dx or 0 end end
function Dp:getdy() if self.__mv==nil then return 0 else return self.__mv.dy or 0 end end
function Dp:getdrot() if self.__mv==nil then return 0 else return self.__mv.drot or 0 end end
function Dp:getdscale() if self.__mv==nil then return 0 else return self.__mv.dscale or 0 end end
function Dp:getdalpha() if self.__mv==nil then return 0 else return self.__mv.dalpha or 0 end end
function Dp:getdxscale() if self.__mv==nil then return 0 else return self.__mv.dxscale or 0 end end
function Dp:getdyscale() if self.__mv==nil then return 0 else return self.__mv.dyscale or 0 end end

function Dp:getdxdy()
    if self.__mv==nil then return 0, 0
    else return (self.__mv.dx or 0), (self.__mv.dy or 0) end
end

--------------------------------------------------------------------------------
-- 2021/04/27 : rearranged the methods
--------------------------------------------------------------------------------
Dp.dx = Dp.setdx
Dp.dy = Dp.setdy
Dp.dxdy = Dp.setdxdy
Dp.drot = Dp.setdrot 
Dp.dscale = Dp.setdscale
Dp.dalpha = Dp.setdalpha
Dp.dxscale = Dp.setdxscale
Dp.dyscale = Dp.setdyscale