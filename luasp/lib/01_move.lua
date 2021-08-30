--------------------------------------------------------------------------------
-- 2021/08/11: modified to use internal update
--------------------------------------------------------------------------------

local Dp = Display

local function move(self)
    
    local d = self.__mv
    
    if d.dx then
        self:setx(self:getx() + d.dx)
    end
    
    if d.dy then self:sety(self:gety() + d.dy) end
    if d.drot then self:setrot(self:getrot() +  d.drot) end
    if d.dscale then self:setscale(self:getscale() + d.dscale) end
    if d.dalpha then self:setalpha(self:getalpha() + d.dalpha) end
    
    if d.dxscale then self:setxscale(self:getxscale() + d.dxscale) end
    if d.dyscale then self:setyscale(self:getyscale() + d.dyscale) end
    
end

--[[
function Dp:move(mv)
    
    self.__mv = mv
    self.__iupds[move] = move
    return self
    
end

--]]


function Dp:pausemove()

    self.__iupds[move] = nil
    return self

end


function Dp:resumemove()

    self.__iupds[move] = move
    return self

end


function Dp:stopmove()

    self.__mv = nil
    self.__iupds[move] = nil
    return self

end

--------------------------------------------------------------------------------
-- 2020/02/18, 2021/04/27 : modified as follows
--------------------------------------------------------------------------------
function Dp:setdx(d)

    self.__mv=self.__mv or {}
    self.__mv.dx = d
    self.__iupds[move] = move
    return self

end


function Dp:setdy(d)

    self.__mv=self.__mv or {}
    self.__mv.dy=d
    self.__iupds[move] = move
    return self

end


function Dp:setdrot(d)

    self.__mv = self.__mv or {}
    self.__mv.drot = d
    self.__iupds[move] = move
    return self

end


function Dp:setdscale(d)

    self.__mv = self.__mv or {}
    self.__mv.dscale = d
    self.__iupds[move] = move
    return self

end


function Dp:setdalpha(d)

    self.__mv = self.__mv or {}
    self.__mv.dalpha = d
    self.__iupds[move] = move
    return self

end


function Dp:setdxscale(d)

    self.__mv=self.__mv or {}
    self.__mv.dxscale = d
    self.__iupds[move] = move
    return self

end


function Dp:setdyscale(d)

    self.__mv=self.__mv or {}
    self.__mv.dyscale = d
    self.__iupds[move] = move
    return self

end


function Dp:setdxdy(dx,dy)

    self.__mv=self.__mv or {}
    self.__mv.dx, self.__mv.dy = dx, dy
    self.__iupds[move] = move
    return self

end

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
-- Dp.dx = Dp.setdx
-- Dp.dy = Dp.setdy
-- Dp.dxdy = Dp.setdxdy
-- Dp.drot = Dp.setdrot 
-- Dp.dscale = Dp.setdscale
-- Dp.dalpha = Dp.setdalpha
-- Dp.dxscale = Dp.setdxscale
-- Dp.dyscale = Dp.setdyscale