--------------------------------------------------------------------------------
-- 2021/08/11: modified to use internal update
--------------------------------------------------------------------------------

local Dp = Display

local function move(self)
    
    local d = self.__mv
    
    if d.dx then
        self:setX(self:getX() + d.dx)
    end
    
    if d.dy then self:setY(self:getY() + d.dy) end
    if d.drot then self:setRot(self:getRot() +  d.drot) end
    if d.dscale then self:setScale(self:getScale() + d.dscale) end
    if d.dalpha then self:setAlpha(self:getAlpha() + d.dalpha) end
    
    if d.dxscale then self:setScaleX(self:getScaleX() + d.dxscale) end
    if d.dyscale then self:setScaleY(self:getScaleY() + d.dyscale) end
    
end


function Dp:pauseMove()

    self.__iupds[move] = nil
    return self

end


function Dp:resumeMove()

    self.__iupds[move] = move
    return self

end


function Dp:stopMove()

    self.__mv = nil
    self.__iupds[move] = nil
    return self

end

--------------------------------------------------------------------------------
-- 2020/02/18, 2021/04/27 : modified as follows
--------------------------------------------------------------------------------
function Dp:setDx(d)

    self.__mv=self.__mv or {}
    self.__mv.dx = d
    self.__iupds[move] = move
    return self

end


function Dp:setDy(d)

    self.__mv=self.__mv or {}
    self.__mv.dy=d
    self.__iupds[move] = move
    return self

end


function Dp:setDrot(d)

    self.__mv = self.__mv or {}
    self.__mv.drot = d
    self.__iupds[move] = move
    return self

end


function Dp:setDscale(d)

    self.__mv = self.__mv or {}
    self.__mv.dscale = d
    self.__iupds[move] = move
    return self

end


function Dp:setDalpha(d)

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


function Dp:setDxDy(dx,dy)

    self.__mv=self.__mv or {}
    self.__mv.dx, self.__mv.dy = dx, dy
    self.__iupds[move] = move
    return self

end

--------------------------------------------------------------------------------
-- 2020/02/25 : add getd() methods
--------------------------------------------------------------------------------
function Dp:getDx() if self.__mv==nil then return 0 else return self.__mv.dx or 0 end end
function Dp:getDy() if self.__mv==nil then return 0 else return self.__mv.dy or 0 end end
function Dp:getDrot() if self.__mv==nil then return 0 else return self.__mv.drot or 0 end end
function Dp:getDscale() if self.__mv==nil then return 0 else return self.__mv.dscale or 0 end end
function Dp:getDalpha() if self.__mv==nil then return 0 else return self.__mv.dalpha or 0 end end
function Dp:getDscaleX() if self.__mv==nil then return 0 else return self.__mv.dxscale or 0 end end
function Dp:getDscaleY() if self.__mv==nil then return 0 else return self.__mv.dyscale or 0 end end

function Dp:getDxDy()
    if self.__mv==nil then return 0, 0
    else return (self.__mv.dx or 0), (self.__mv.dy or 0) end
end